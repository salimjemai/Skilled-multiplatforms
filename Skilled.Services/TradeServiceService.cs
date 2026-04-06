using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using Skilled.Data;
using Skilled.Data.Models;
using System.Net.Http.Json;

namespace Skilled.Services;

public interface ITradeServiceService
{
    Task<List<TradeService>> GetServicesAsync();
    Task<List<TradeService>> GetServicesByCategoryAsync(TradeCategory category);
    Task<List<TradeService>> GetServicesByProviderIdAsync(Guid providerId);
    Task<TradeService> GetServiceAsync(Guid serviceId);
    Task<bool> CreateServiceAsync(TradeService service);
    Task<bool> UpdateServiceAsync(TradeService service);
    Task<bool> DeleteServiceAsync(Guid serviceId);
}

public class TradeServiceService : ITradeServiceService
{
    private readonly ILogger<TradeServiceService> _logger;
    private readonly IHttpClientFactory _httpClientFactory;
    private readonly IPreferenceService _preferenceService;
    private readonly string _apiBaseUrl = "https://skilled-api.yourdomain.com/api"; // Replace with your API URL

    public TradeServiceService(
        ILogger<TradeServiceService> logger,
        IHttpClientFactory httpClientFactory,
        IPreferenceService preferenceService)
    {
        _logger = logger;
        _httpClientFactory = httpClientFactory;
        _preferenceService = preferenceService;
    }

    public async Task<List<TradeService>> GetServicesAsync()
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
            var response = await client.GetAsync($"{_apiBaseUrl}/services");
            if (response.IsSuccessStatusCode)
            {
                var servicesFromApi = await response.Content.ReadFromJsonAsync<List<TradeService>>();
                return servicesFromApi ?? new List<TradeService>();
            }
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error getting services from API");
        }
        return new List<TradeService>();
    }

    public async Task<List<TradeService>> GetServicesByCategoryAsync(TradeCategory category)
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
            var response = await client.GetAsync($"{_apiBaseUrl}/services/category/{category}");
            if (response.IsSuccessStatusCode)
            {
                var servicesFromApi = await response.Content.ReadFromJsonAsync<List<TradeService>>();
                return servicesFromApi ?? new List<TradeService>();
            }
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error getting services by category from API");
        }
        return new List<TradeService>();
    }

    public async Task<List<TradeService>> GetServicesByProviderIdAsync(Guid providerId)
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
            var response = await client.GetAsync($"{_apiBaseUrl}/services/provider/{providerId}");
            if (response.IsSuccessStatusCode)
            {
                var servicesFromApi = await response.Content.ReadFromJsonAsync<List<TradeService>>();
                return servicesFromApi ?? new List<TradeService>();
            }
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error getting services by provider from API");
        }
        return new List<TradeService>();
    }

    public async Task<TradeService> GetServiceAsync(Guid serviceId)
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
            var response = await client.GetAsync($"{_apiBaseUrl}/services/{serviceId}");
            if (response.IsSuccessStatusCode)
            {
                var serviceFromApi = await response.Content.ReadFromJsonAsync<TradeService>();
                return serviceFromApi;
            }
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error getting service from API");
        }
        return null;
    }

    public async Task<bool> CreateServiceAsync(TradeService service)
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
            var response = await client.PostAsJsonAsync($"{_apiBaseUrl}/services", service);
            if (response.IsSuccessStatusCode)
            {
                var createdService = await response.Content.ReadFromJsonAsync<TradeService>();
                return createdService != null;
            }
            return false;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error creating service via API");
            return false;
        }
    }

    public async Task<bool> UpdateServiceAsync(TradeService service)
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
            var response = await client.PutAsJsonAsync($"{_apiBaseUrl}/services/{service.Id}", service);
            if (response.IsSuccessStatusCode)
            {
                var updatedService = await response.Content.ReadFromJsonAsync<TradeService>();
                return updatedService != null;
            }
            return false;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error updating service via API");
            return false;
        }
    }

    public async Task<bool> DeleteServiceAsync(Guid serviceId)
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
            var response = await client.DeleteAsync($"{_apiBaseUrl}/services/{serviceId}");
            return response.IsSuccessStatusCode;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error deleting service via API");
            return false;
        }
    }
}