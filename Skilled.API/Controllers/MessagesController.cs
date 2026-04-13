using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Skilled.API.DTOs;
using Skilled.Data;
using Skilled.Data.Models;
using System.Security.Claims;

namespace Skilled.API.Controllers;

[ApiController]
[Route("api/messages")]
[Authorize]
public class MessagesController : ControllerBase
{
    private readonly SkilledDbContext _db;

    public MessagesController(SkilledDbContext db) => _db = db;

    private Guid CurrentUserId =>
        Guid.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);

    // GET api/messages/chats  — list of conversations for current user
    [HttpGet("chats")]
    public async Task<IActionResult> GetChats()
    {
        var userId = CurrentUserId;

        // Build unique conversation partners
        var sent = await _db.ChatMessages
            .Include(m => m.Receiver)
            .Where(m => m.SenderId == userId)
            .GroupBy(m => m.ReceiverId)
            .Select(g => new
            {
                OtherUserId = g.Key,
                OtherUser = g.First().Receiver,
                LastMessage = g.OrderByDescending(m => m.SentAt).First().Message,
                LastMessageTime = g.Max(m => m.SentAt),
                UnreadCount = 0
            })
            .ToListAsync();

        var received = await _db.ChatMessages
            .Include(m => m.Sender)
            .Where(m => m.ReceiverId == userId)
            .GroupBy(m => m.SenderId)
            .Select(g => new
            {
                OtherUserId = g.Key,
                OtherUser = g.First().Sender,
                LastMessage = g.OrderByDescending(m => m.SentAt).First().Message,
                LastMessageTime = g.Max(m => m.SentAt),
                UnreadCount = g.Count(m => !m.IsRead)
            })
            .ToListAsync();

        // Merge and deduplicate
        var allPartnerIds = sent.Select(s => s.OtherUserId)
            .Union(received.Select(r => r.OtherUserId))
            .Distinct();

        var chats = allPartnerIds.Select(partnerId =>
        {
            var s = sent.FirstOrDefault(x => x.OtherUserId == partnerId);
            var r = received.FirstOrDefault(x => x.OtherUserId == partnerId);
            var otherUser = s?.OtherUser ?? r?.OtherUser;
            var lastTime = new[] { s?.LastMessageTime, r?.LastMessageTime }
                .Where(t => t.HasValue).Max();

            return new ChatPreviewDto
            {
                Id = partnerId,
                OtherUserId = partnerId,
                Name = otherUser?.FullName ?? "Unknown",
                ProfileImage = otherUser?.ProfileImageUrl ?? string.Empty,
                LastMessage = lastTime == s?.LastMessageTime ? (s?.LastMessage ?? "") : (r?.LastMessage ?? ""),
                LastMessageTime = lastTime ?? DateTime.UtcNow,
                UnreadCount = r?.UnreadCount ?? 0
            };
        })
        .OrderByDescending(c => c.LastMessageTime)
        .ToList();

        return Ok(chats);
    }

    // GET api/messages/chats/{otherUserId}  — messages with a specific user
    [HttpGet("chats/{otherUserId:guid}")]
    public async Task<IActionResult> GetConversation(Guid otherUserId, [FromQuery] int page = 1, [FromQuery] int pageSize = 50)
    {
        var userId = CurrentUserId;

        var messages = await _db.ChatMessages
            .Include(m => m.Sender)
            .Where(m =>
                (m.SenderId == userId && m.ReceiverId == otherUserId) ||
                (m.SenderId == otherUserId && m.ReceiverId == userId))
            .OrderByDescending(m => m.SentAt)
            .Skip((page - 1) * pageSize)
            .Take(pageSize)
            .ToListAsync();

        // Mark received messages as read
        var unread = messages.Where(m => m.ReceiverId == userId && !m.IsRead).ToList();
        foreach (var msg in unread)
        {
            msg.IsRead = true;
            msg.ReadAt = DateTime.UtcNow;
        }
        if (unread.Any()) await _db.SaveChangesAsync();

        return Ok(messages.OrderBy(m => m.SentAt).Select(MessageDto.FromMessage));
    }

    // POST api/messages/chats/{otherUserId}  — send a message
    [HttpPost("chats/{otherUserId:guid}")]
    public async Task<IActionResult> SendMessage(Guid otherUserId, [FromBody] SendMessageRequest req)
    {
        var receiver = await _db.Users.FindAsync(otherUserId);
        if (receiver == null) return BadRequest(new { message = "Recipient not found." });

        var message = new ChatMessage
        {
            Id = Guid.NewGuid(),
            SenderId = CurrentUserId,
            ReceiverId = otherUserId,
            Message = req.Message,
            MessageType = MessageType.Text,
            SentAt = DateTime.UtcNow,
            IsRead = false
        };

        _db.ChatMessages.Add(message);
        await _db.SaveChangesAsync();

        // Reload with navigation
        await _db.Entry(message).Reference(m => m.Sender).LoadAsync();
        return Ok(MessageDto.FromMessage(message));
    }
}
