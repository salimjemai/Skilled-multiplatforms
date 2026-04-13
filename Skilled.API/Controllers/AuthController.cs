using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using Skilled.API.DTOs;
using Skilled.Data;
using Skilled.Data.Models;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Security.Cryptography;
using System.Text;

namespace Skilled.API.Controllers;

[ApiController]
[Route("api/auth")]
public class AuthController : ControllerBase
{
    private readonly SkilledDbContext _db;
    private readonly IConfiguration _config;
    private readonly IPasswordHasher<User> _hasher;
    private readonly ILogger<AuthController> _logger;

    public AuthController(
        SkilledDbContext db,
        IConfiguration config,
        IPasswordHasher<User> hasher,
        ILogger<AuthController> logger)
    {
        _db = db;
        _config = config;
        _hasher = hasher;
        _logger = logger;
    }

    // POST api/auth/register
    [HttpPost("register")]
    [AllowAnonymous]
    public async Task<IActionResult> Register([FromBody] RegisterRequest req)
    {
        if (!ModelState.IsValid)
            return BadRequest(ModelState);

        if (await _db.Users.AnyAsync(u => u.Email == req.Email.ToLower()))
            return Conflict(new { message = "Email is already registered." });

        var user = new User
        {
            Id = Guid.NewGuid(),
            FirstName = req.FirstName,
            LastName = req.LastName,
            Email = req.Email.ToLower(),
            Role = req.Role,
            CreatedAt = DateTime.UtcNow,
            UpdatedAt = DateTime.UtcNow
        };
        user.PasswordHash = _hasher.HashPassword(user, req.Password);

        _db.Users.Add(user);
        await _db.SaveChangesAsync();

        _logger.LogInformation("User registered: {Email}", user.Email);
        return Ok(BuildAuthResponse(user));
    }

    // POST api/auth/login
    [HttpPost("login")]
    [AllowAnonymous]
    public async Task<IActionResult> Login([FromBody] LoginRequest req)
    {
        if (!ModelState.IsValid)
            return BadRequest(ModelState);

        var user = await _db.Users.FirstOrDefaultAsync(u => u.Email == req.Email.ToLower());
        if (user == null)
            return Unauthorized(new { message = "Invalid email or password." });

        var result = _hasher.VerifyHashedPassword(user, user.PasswordHash, req.Password);
        if (result == PasswordVerificationResult.Failed)
            return Unauthorized(new { message = "Invalid email or password." });

        _logger.LogInformation("User logged in: {Email}", user.Email);
        return Ok(BuildAuthResponse(user));
    }

    // POST api/auth/refresh
    [HttpPost("refresh")]
    [AllowAnonymous]
    public async Task<IActionResult> Refresh([FromBody] RefreshTokenRequest req)
    {
        // Validate the refresh token (it's a signed JWT itself)
        var principal = ValidateToken(req.RefreshToken);
        if (principal == null)
            return Unauthorized(new { message = "Invalid or expired refresh token." });

        var userIdStr = principal.FindFirstValue(ClaimTypes.NameIdentifier);
        if (!Guid.TryParse(userIdStr, out var userId))
            return Unauthorized(new { message = "Invalid token." });

        var user = await _db.Users.FindAsync(userId);
        if (user == null)
            return Unauthorized(new { message = "User not found." });

        return Ok(BuildAuthResponse(user));
    }

    // POST api/auth/logout
    [HttpPost("logout")]
    [Authorize]
    public IActionResult Logout()
    {
        // Stateless JWT — client just discards the token.
        return Ok(new { message = "Logged out successfully." });
    }

    // POST api/auth/reset-password
    [HttpPost("reset-password")]
    [AllowAnonymous]
    public async Task<IActionResult> ResetPassword([FromBody] ResetPasswordRequest req)
    {
        var user = await _db.Users.FirstOrDefaultAsync(u => u.Email == req.Email.ToLower());
        if (user == null)
            return Ok(new { message = "If that email exists, a reset link has been sent." });

        // TODO: integrate an email provider (SendGrid / Mailgun) and send a real reset link.
        _logger.LogInformation("Password reset requested for {Email}", req.Email);
        return Ok(new { message = "If that email exists, a reset link has been sent." });
    }

    // ── Helpers ──────────────────────────────────────────────────────────────

    private AuthResponse BuildAuthResponse(User user)
    {
        var key = _config["Jwt:Key"] ?? throw new InvalidOperationException("JWT key not configured.");
        var expiryHours = int.TryParse(_config["Jwt:ExpiryHours"], out var h) ? h : 24;
        var issuer = _config["Jwt:Issuer"] ?? "SkilledAPI";
        var audience = _config["Jwt:Audience"] ?? "SkilledApp";

        var claims = new[]
        {
            new Claim(ClaimTypes.NameIdentifier, user.Id.ToString()),
            new Claim(ClaimTypes.Email, user.Email),
            new Claim(ClaimTypes.Role, user.Role.ToString()),
            new Claim("firstName", user.FirstName),
            new Claim("lastName", user.LastName)
        };

        var signingKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(key));
        var creds = new SigningCredentials(signingKey, SecurityAlgorithms.HmacSha256);
        var expiry = DateTime.UtcNow.AddHours(expiryHours);

        var token = new JwtSecurityToken(
            issuer: issuer,
            audience: audience,
            claims: claims,
            expires: expiry,
            signingCredentials: creds);

        // Refresh token — longer-lived JWT with "refresh" claim
        var refreshClaims = new[]
        {
            new Claim(ClaimTypes.NameIdentifier, user.Id.ToString()),
            new Claim("type", "refresh")
        };
        var refreshToken = new JwtSecurityToken(
            issuer: issuer,
            audience: audience,
            claims: refreshClaims,
            expires: DateTime.UtcNow.AddDays(30),
            signingCredentials: creds);

        return new AuthResponse
        {
            Token = new JwtSecurityTokenHandler().WriteToken(token),
            RefreshToken = new JwtSecurityTokenHandler().WriteToken(refreshToken),
            ExpiresAt = expiry,
            User = UserDto.FromUser(user)
        };
    }

    private ClaimsPrincipal? ValidateToken(string token)
    {
        var key = _config["Jwt:Key"];
        if (string.IsNullOrEmpty(key)) return null;

        var handler = new JwtSecurityTokenHandler();
        var validationParams = new TokenValidationParameters
        {
            ValidateIssuerSigningKey = true,
            IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(key)),
            ValidateIssuer = true,
            ValidIssuer = _config["Jwt:Issuer"],
            ValidateAudience = true,
            ValidAudience = _config["Jwt:Audience"],
            ValidateLifetime = true,
            ClockSkew = TimeSpan.Zero
        };

        try
        {
            return handler.ValidateToken(token, validationParams, out _);
        }
        catch
        {
            return null;
        }
    }
}

public class ResetPasswordRequest
{
    public string Email { get; set; } = string.Empty;
}
