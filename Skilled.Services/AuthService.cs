using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using Skilled.Data.Models;
using System.IdentityModel.Tokens.Jwt;
using System.Net.Http.Json;

namespace Skilled.Services;

public interface IAuthService
{
    Task<User?> GetCurrentUserAsync();
    Task<bool> LoginAsync(string email, string password);
    Task<bool> RegisterAsync(string firstName, string lastName, string email, string password, UserRole role);
    Task<bool> LogoutAsync();
    Task<bool> IsAuthenticatedAsync();
    Task<bool> ResetPasswordAsync(string email);
    Task<bool> UpdateUserProfileAsync(User user);
}

public class AuthService : IAuthService
{
    private readonly ILogger<AuthService> _logger;
    private readonly IHttpClientFactory _httpClientFactory;
    private readonly IPreferenceService _preferenceService;
    private readonly string _apiBaseUrl;

    private const string TokenKey       = "auth_token";
    private const string RefreshTokenKey = "refresh_token";
    private const string CurrentUserKey  = "current_user";

    public AuthService(
        ILogger<AuthService> logger,
        IHttpClientFactory httpClientFactory,
        IPreferenceService preferenceService,
        IConfiguration configuration)
    {
        _logger = logger;
        _httpClientFactory = httpClientFactory;
        _preferenceService = preferenceService;
        _apiBaseUrl = configuration["ApiSettings:BaseUrl"]
                      ?? "http://localhost:5000/api";
    }

    /// <summary>Gets the currently authenticated user by calling /users/me.</summary>
    public async Task<User?> GetCurrentUserAsync()
    {
        var token = _preferenceService.Get<string>(TokenKey);
        if (string.IsNullOrEmpty(token))
            return null;

        try
        {
            var client = _httpClientFactory.CreateClient("SkilledApi");
            client.DefaultRequestHeaders.Authorization =
                new System.Net.Http.Headers.AuthenticationHeaderValue("Bearer", token);

            var response = await client.GetAsync($"{_apiBaseUrl}/users/me");
            if (response.IsSuccessStatusCode)
                return await response.Content.ReadFromJsonAsync<User>();
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error getting current user from API");
        }

        return null;
    }

    /// <summary>Logs in with email and password. Does NOT require being pre-authenticated.</summary>
    public async Task<bool> LoginAsync(string email, string password)
    {
        try
        {
            var client = _httpClientFactory.CreateClient("SkilledApi");
            var content = new { email, password };

            var response = await client.PostAsJsonAsync($"{_apiBaseUrl}/auth/login", content);
            if (!response.IsSuccessStatusCode)
                return false;

            var authResponse = await response.Content.ReadFromJsonAsync<AuthResponse>();
            if (authResponse == null)
                return false;

            _preferenceService.Set(TokenKey, authResponse.Token);
            _preferenceService.Set(RefreshTokenKey, authResponse.RefreshToken);
            _preferenceService.Set(CurrentUserKey, authResponse.User.Id.ToString());

            return true;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error during login");
            return false;
        }
    }

    /// <summary>Registers a new user account.</summary>
    public async Task<bool> RegisterAsync(
        string firstName, string lastName,
        string email, string password, UserRole role)
    {
        try
        {
            var client = _httpClientFactory.CreateClient("SkilledApi");
            var content = new
            {
                firstName,
                lastName,
                email,
                password,
                role = role.ToString()
            };

            var response = await client.PostAsJsonAsync($"{_apiBaseUrl}/auth/register", content);
            if (!response.IsSuccessStatusCode)
                return false;

            var authResponse = await response.Content.ReadFromJsonAsync<AuthResponse>();
            if (authResponse == null)
                return false;

            _preferenceService.Set(TokenKey, authResponse.Token);
            _preferenceService.Set(RefreshTokenKey, authResponse.RefreshToken);
            _preferenceService.Set(CurrentUserKey, authResponse.User.Id.ToString());

            return true;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error during registration");
            return false;
        }
    }

    /// <summary>Logs out the user, clearing stored tokens.</summary>
    public async Task<bool> LogoutAsync()
    {
        try
        {
            var token = _preferenceService.Get<string>(TokenKey);
            if (!string.IsNullOrEmpty(token))
            {
                var client = _httpClientFactory.CreateClient("SkilledApi");
                client.DefaultRequestHeaders.Authorization =
                    new System.Net.Http.Headers.AuthenticationHeaderValue("Bearer", token);
                try { await client.PostAsync($"{_apiBaseUrl}/auth/logout", null); }
                catch (Exception ex)
                {
                    _logger.LogWarning(ex, "Error calling logout API, continuing with local logout");
                }
            }
        }
        finally
        {
            _preferenceService.Remove(TokenKey);
            _preferenceService.Remove(RefreshTokenKey);
            _preferenceService.Remove(CurrentUserKey);
        }

        return true;
    }

    /// <summary>Returns true if a valid, non-expired JWT is stored locally.</summary>
    public async Task<bool> IsAuthenticatedAsync()
    {
        var token = _preferenceService.Get<string>(TokenKey);
        if (string.IsNullOrEmpty(token))
            return false;

        try
        {
            var jwtToken = new JwtSecurityTokenHandler().ReadJwtToken(token);
            if (jwtToken.ValidTo >= DateTime.UtcNow)
                return true;

            // Token expired — try refresh
            return await RefreshTokenAsync();
        }
        catch
        {
            return false;
        }
    }

    /// <summary>Refreshes the access token using the stored refresh token.</summary>
    private async Task<bool> RefreshTokenAsync()
    {
        var refreshToken = _preferenceService.Get<string>(RefreshTokenKey);
        if (string.IsNullOrEmpty(refreshToken))
            return false;

        try
        {
            var client = _httpClientFactory.CreateClient("SkilledApi");
            var response = await client.PostAsJsonAsync(
                $"{_apiBaseUrl}/auth/refresh", new { refreshToken });

            if (!response.IsSuccessStatusCode)
                return false;

            var authResponse = await response.Content.ReadFromJsonAsync<AuthResponse>();
            if (authResponse == null)
                return false;

            _preferenceService.Set(TokenKey, authResponse.Token);
            _preferenceService.Set(RefreshTokenKey, authResponse.RefreshToken);
            return true;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error refreshing token");
            return false;
        }
    }

    public async Task<bool> ResetPasswordAsync(string email)
    {
        try
        {
            var client = _httpClientFactory.CreateClient("SkilledApi");
            var response = await client.PostAsJsonAsync(
                $"{_apiBaseUrl}/auth/reset-password", new { email });
            return response.IsSuccessStatusCode;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error resetting password");
            return false;
        }
    }

    public async Task<bool> UpdateUserProfileAsync(User user)
    {
        try
        {
            var token = _preferenceService.Get<string>(TokenKey);
            if (string.IsNullOrEmpty(token))
                return false;

            var client = _httpClientFactory.CreateClient("SkilledApi");
            client.DefaultRequestHeaders.Authorization =
                new System.Net.Http.Headers.AuthenticationHeaderValue("Bearer", token);

            var response = await client.PutAsJsonAsync($"{_apiBaseUrl}/users/{user.Id}", user);
            return response.IsSuccessStatusCode;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error updating user profile");
            return false;
        }
    }
}

/// <summary>Matches the API's AuthResponse DTO shape.</summary>
public class AuthResponse
{
    public string Token { get; set; } = string.Empty;
    public string RefreshToken { get; set; } = string.Empty;
    public DateTime ExpiresAt { get; set; }
    public AuthUserDto User { get; set; } = null!;
}

public class AuthUserDto
{
    public Guid Id { get; set; }
    public string FirstName { get; set; } = string.Empty;
    public string LastName { get; set; } = string.Empty;
    public string Email { get; set; } = string.Empty;
    public string Role { get; set; } = string.Empty;
}
