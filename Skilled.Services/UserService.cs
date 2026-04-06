using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using Skilled.Data;
using Skilled.Data.Models;
using System.Net.Http.Json;

namespace Skilled.Services;

public interface IUserService
{
    Task<User> GetUserAsync(Guid userId);
    Task<List<User>> GetServiceProvidersAsync();
    Task<List<User>> GetServiceProvidersByCategoryAsync(TradeCategory category);
    Task<bool> UpdateUserAsync(User user);
}

public class UserService : IUserService
{
    private readonly ILogger<UserService> _logger;
    private readonly IHttpClientFactory _httpClientFactory;
    private readonly IPreferenceService _preferenceService;
    private readonly string _apiBaseUrl = "https://skilled-api.yourdomain.com/api"; // Replace with your API URL

    public UserService(
        ILogger<UserService> logger,
        IHttpClientFactory httpClientFactory,
        IPreferenceService preferenceService)
    {
        _logger = logger;
        _httpClientFactory = httpClientFactory;
        _preferenceService = preferenceService;
    }

    public async Task<User> GetUserAsync(Guid userId)
    {
        // Use API only (mock data or API call)
        try
        {
            var token = _preferenceService.Get<string>("auth_token");
            if (string.IsNullOrEmpty(token))
            {
                return null;
            }
            var client = _httpClientFactory.CreateClient("SkilledApi");
            client.DefaultRequestHeaders.Authorization = new System.Net.Http.Headers.AuthenticationHeaderValue("Bearer", token);
            var response = await client.GetAsync($"{_apiBaseUrl}/users/{userId}");
            if (response.IsSuccessStatusCode)
            {
                var userFromApi = await response.Content.ReadFromJsonAsync<User>();
                return userFromApi;
            }
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error getting user from API");
        }
        return null;
    }

    public async Task<List<User>> GetServiceProvidersAsync()
    {
        // Use API only (mock data or API call)
        try
        {
            var client = _httpClientFactory.CreateClient("SkilledApi");
            var token = _preferenceService.Get<string>("auth_token");
            if (!string.IsNullOrEmpty(token))
            {
                client.DefaultRequestHeaders.Authorization = new System.Net.Http.Headers.AuthenticationHeaderValue("Bearer", token);
            }
            var response = await client.GetAsync($"{_apiBaseUrl}/users/providers");
            if (response.IsSuccessStatusCode)
            {
                var providersFromApi = await response.Content.ReadFromJsonAsync<List<User>>();
                return providersFromApi ?? new List<User>();
            }
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error getting service providers from API");
        }
        return new List<User>();
    }

    public async Task<List<User>> GetServiceProvidersByCategoryAsync(TradeCategory category)
    {
        // Use API only (mock data or API call)
        try
        {
            var client = _httpClientFactory.CreateClient("SkilledApi");
            var token = _preferenceService.Get<string>("auth_token");
            if (!string.IsNullOrEmpty(token))
            {
                client.DefaultRequestHeaders.Authorization = new System.Net.Http.Headers.AuthenticationHeaderValue("Bearer", token);
            }
            var response = await client.GetAsync($"{_apiBaseUrl}/users/providers/category/{category}");
            if (response.IsSuccessStatusCode)
            {
                var providersFromApi = await response.Content.ReadFromJsonAsync<List<User>>();
                return providersFromApi ?? new List<User>();
            }
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error getting service providers by category from API");
        }
        return new List<User>();
    }

    public async Task<bool> UpdateUserAsync(User user)
    {
        try
        {
            var token = _preferenceService.Get<string>("auth_token");
            if (string.IsNullOrEmpty(token))
            {
                return false;
            }
            var client = _httpClientFactory.CreateClient("SkilledApi");
            client.DefaultRequestHeaders.Authorization = new System.Net.Http.Headers.AuthenticationHeaderValue("Bearer", token);
            var response = await client.PutAsJsonAsync($"{_apiBaseUrl}/users/{user.Id}", user);
            if (response.IsSuccessStatusCode)
            {
                var updatedUser = await response.Content.ReadFromJsonAsync<User>();
                return updatedUser != null;
            }
            return false;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error updating user via API");
            return false;
        }
    }
}