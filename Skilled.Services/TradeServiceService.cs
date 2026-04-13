using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using Skilled.Data.Models;
using System.Net.Http.Json;

namespace Skilled.Services;

public interface ITradeServiceService
{
    Task<List<TradeService>> GetServicesAsync();
    Task<List<TradeService>> GetServicesByCategoryAsync(Guid categoryId);
    Task<List<TradeService>> GetServicesByProviderIdAsync(Guid providerId);
    Task<TradeService?> GetServiceAsync(Guid serviceId);
    Task<bool> CreateServiceAsync(TradeService service);
    Task<bool> UpdateServiceAsync(TradeService service);
    Task<bool> DeleteServiceAsync(Guid serviceId);
    Task<List<TradeCategory>> GetCategoriesAsync();
}

public class TradeServiceService : ITradeServiceService
{
    private readonly ILogger<TradeServiceService> _logger;
    private readonly IHttpClientFactory _httpClientFactory;
    private readonly IPreferenceService _preferenceService;
    private readonly string _apiBaseUrl;

    public TradeServiceService(
        ILogger<TradeServiceService> logger,
        IHttpClientFactory httpClientFactory,
        IPreferenceService preferenceService,
        IConfiguration configuration)
    {
        _logger = logger;
        _httpClientFactory = httpClientFactory;
        _preferenceService = preferenceService;
        _apiBaseUrl = configuration["ApiSettings:BaseUrl"] ?? "http://localhost:5000/api";
    }

    private HttpClient CreateClient(bool authorized = false)
    {
        var client = _httpClientFactory.CreateClient("SkilledApi");
        if (authorized)
        {
            var token = _preferenceService.Get<string>("auth_token");
            if (!string.IsNullOrEmpty(token))
                client.DefaultRequestHeaders.Authorization =
                    new System.Net.Http.Headers.AuthenticationHeaderValue("Bearer", token);
        }
        return client;
    }

    public async Task<List<TradeService>> GetServicesAsync()
    {
        try
        {
            var response = await CreateClient().GetAsync($"{_apiBaseUrl}/services");
            if (response.IsSuccessStatusCode)
                return await response.Content.ReadFromJsonAsync<List<TradeService>>()
                       ?? new List<TradeService>();
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error getting services");
        }
        return new List<TradeService>();
    }

    /// <summary>
    /// Fixed: passes categoryId (Guid) in the URL, not the full TradeCategory object.
    /// </summary>
    public async Task<List<TradeService>> GetServicesByCategoryAsync(Guid categoryId)
    {
        try
        {
            var response = await CreateClient().GetAsync(
                $"{_apiBaseUrl}/services/category/{categoryId}");
            if (response.IsSuccessStatusCode)
                return await response.Content.ReadFromJsonAsync<List<TradeService>>()
                       ?? new List<TradeService>();
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error getting services for category {CategoryId}", categoryId);
        }
        return new List<TradeService>();
    }

    public async Task<List<TradeService>> GetServicesByProviderIdAsync(Guid providerId)
    {
        try
        {
            var response = await CreateClient().GetAsync(
                $"{_apiBaseUrl}/services/provider/{providerId}");
            if (response.IsSuccessStatusCode)
                return await response.Content.ReadFromJsonAsync<List<TradeService>>()
                       ?? new List<TradeService>();
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error getting services for provider {ProviderId}", providerId);
        }
        return new List<TradeService>();
    }

    public async Task<TradeService?> GetServiceAsync(Guid serviceId)
    {
        try
        {
            var response = await CreateClient().GetAsync($"{_apiBaseUrl}/services/{serviceId}");
            if (response.IsSuccessStatusCode)
                return await response.Content.ReadFromJsonAsync<TradeService>();
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error getting service {ServiceId}", serviceId);
        }
        return null;
    }

    public async Task<List<TradeCategory>> GetCategoriesAsync()
    {
        try
        {
            var response = await CreateClient().GetAsync($"{_apiBaseUrl}/services/categories");
            if (response.IsSuccessStatusCode)
                return await response.Content.ReadFromJsonAsync<List<TradeCategory>>()
                       ?? new List<TradeCategory>();
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error getting categories");
        }
        return new List<TradeCategory>();
    }

    public async Task<bool> CreateServiceAsync(TradeService service)
    {
        try
        {
            var response = await CreateClient(authorized: true)
                .PostAsJsonAsync($"{_apiBaseUrl}/services", service);
            return response.IsSuccessStatusCode;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error creating service");
            return false;
        }
    }

    public async Task<bool> UpdateServiceAsync(TradeService service)
    {
        try
        {
            var response = await CreateClient(authorized: true)
                .PutAsJsonAsync($"{_apiBaseUrl}/services/{service.Id}", service);
            return response.IsSuccessStatusCode;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error updating service");
            return false;
        }
    }

    public async Task<bool> DeleteServiceAsync(Guid serviceId)
    {
        try
        {
            var response = await CreateClient(authorized: true)
                .DeleteAsync($"{_apiBaseUrl}/services/{serviceId}");
            return response.IsSuccessStatusCode;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error deleting service {ServiceId}", serviceId);
            return false;
        }
    }
}
