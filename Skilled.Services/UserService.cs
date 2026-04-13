using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using Skilled.Data.Models;
using System.Net.Http.Json;

namespace Skilled.Services;

public interface IUserService
{
    Task<User?> GetUserAsync(Guid userId);
    Task<List<User>> GetServiceProvidersAsync();
    Task<List<ServiceProvider>> GetServiceProvidersByCategoryAsync(Guid categoryId);
    Task<bool> UpdateUserAsync(User user);
}

public class UserService : IUserService
{
    private readonly ILogger<UserService> _logger;
    private readonly IHttpClientFactory _httpClientFactory;
    private readonly IPreferenceService _preferenceService;
    private readonly string _apiBaseUrl;

    public UserService(
        ILogger<UserService> logger,
        IHttpClientFactory httpClientFactory,
        IPreferenceService preferenceService,
        IConfiguration configuration)
    {
        _logger = logger;
        _httpClientFactory = httpClientFactory;
        _preferenceService = preferenceService;
        _apiBaseUrl = configuration["ApiSettings:BaseUrl"] ?? "http://localhost:5000/api";
    }

    private HttpClient CreateAuthorizedClient()
    {
        var client = _httpClientFactory.CreateClient("SkilledApi");
        var token = _preferenceService.Get<string>("auth_token");
        if (!string.IsNullOrEmpty(token))
            client.DefaultRequestHeaders.Authorization =
                new System.Net.Http.Headers.AuthenticationHeaderValue("Bearer", token);
        return client;
    }

    public async Task<User?> GetUserAsync(Guid userId)
    {
        try
        {
            var client = CreateAuthorizedClient();
            var response = await client.GetAsync($"{_apiBaseUrl}/users/{userId}");
            if (response.IsSuccessStatusCode)
                return await response.Content.ReadFromJsonAsync<User>();
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error getting user {UserId}", userId);
        }
        return null;
    }

    public async Task<List<User>> GetServiceProvidersAsync()
    {
        try
        {
            var client = CreateAuthorizedClient();
            var response = await client.GetAsync($"{_apiBaseUrl}/users/providers");
            if (response.IsSuccessStatusCode)
                return await response.Content.ReadFromJsonAsync<List<User>>() ?? new List<User>();
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error getting service providers");
        }
        return new List<User>();
    }

    /// <summary>
    /// Fixed: now passes categoryId (Guid) instead of the full TradeCategory object.
    /// </summary>
    public async Task<List<ServiceProvider>> GetServiceProvidersByCategoryAsync(Guid categoryId)
    {
        try
        {
            var client = CreateAuthorizedClient();
            var response = await client.GetAsync($"{_apiBaseUrl}/users/providers/category/{categoryId}");
            if (response.IsSuccessStatusCode)
                return await response.Content.ReadFromJsonAsync<List<ServiceProvider>>()
                       ?? new List<ServiceProvider>();
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error getting providers for category {CategoryId}", categoryId);
        }
        return new List<ServiceProvider>();
    }

    public async Task<bool> UpdateUserAsync(User user)
    {
        try
        {
            var client = CreateAuthorizedClient();
            var response = await client.PutAsJsonAsync($"{_apiBaseUrl}/users/{user.Id}", user);
            return response.IsSuccessStatusCode;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error updating user");
            return false;
        }
    }
}
