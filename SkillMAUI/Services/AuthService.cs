using Microsoft.Extensions.Identity.Core;
using Microsoft.Extensions.Logging;
using Skilled.Data.Models;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;
using Microsoft.IdentityModel.Tokens;
using System.Net.Http.Json;
using Microsoft.AspNetCore.Identity;
using Skilled.Data;
using Microsoft.EntityFrameworkCore;

namespace Skilled.Services;

public interface IAuthService
{
    /// <summary>
    /// Gets the currently authenticated user.
    /// </summary>
    /// <returns></returns>
    Task<User> GetCurrentUserAsync();

    /// <summary>
    /// Logs in a user with the provided email and password.
    /// </summary>
    /// <param name="email"></param>
    /// <param name="password"></param>
    /// <returns></returns>
    Task<bool> LoginAsync(string email, string password);
    /// <summary>
    ///  Registers a new user with the provided details.
    /// </summary>
    /// <param name="firstName"></param>
    /// <param name="lastName"></param>
    /// <param name="email"></param>
    /// <param name="password"></param>
    /// <param name="role"></param>
    /// <returns></returns>
    Task<bool> RegisterAsync(string firstName, string lastName, string email, string password, UserRole role);
    /// <summary>
    /// Logs out the currently authenticated user.
    /// </summary>
    /// <returns></returns>
    Task<bool> LogoutAsync();
    /// <summary>
    /// Checks if the user is authenticated.
    /// </summary>
    /// <returns></returns>
    Task<bool> IsAuthenticatedAsync();
    /// <summary>
    /// Refreshes the authentication token if it has expired.
    /// </summary>
    /// <param name="email"></param>
    /// <returns></returns>
    Task<bool> ResetPasswordAsync(string email);
    /// <summary>
    /// Updates the user profile with the provided user details.
    /// </summary>
    /// <param name="user"></param>
    /// <returns></returns>
    Task<bool> UpdateUserProfileAsync(User user);
}

/// <summary>
/// Service for handling authentication operations such as login, registration, and user management.
/// </summary>
public class AuthService : IAuthService
{
    private readonly ILogger<AuthService> _logger;
    private readonly IHttpClientFactory _httpClientFactory;
    private readonly IPreferenceService _preferenceService;
    private readonly string ApiBaseUrl = "https://skilled-api.yourdomain.com/api"; // Replace with your API URL
    
    private const string TokenKey = "auth_token";
    private const string RefreshTokenKey = "refresh_token";
    private const string CurrentUserKey = "current_user";

    /// <summary>
    /// Initializes a new instance of the <see cref="AuthService"/> class.
    /// </summary>
    /// <param name="logger"></param>
    /// <param name="httpClientFactory"></param>
    /// <param name="preferenceService"></param>
    public AuthService(
        ILogger<AuthService> logger,
        IHttpClientFactory httpClientFactory,
        IPreferenceService preferenceService)
    {
        _logger = logger;
        _httpClientFactory = httpClientFactory;
        _preferenceService = preferenceService;
    }

    /// <summary>
    /// Gets the currently authenticated user from local database or API.
    /// </summary>
    /// <returns></returns>
    public async Task<User> GetCurrentUserAsync()
    {
        // First try to get from preferences
        var userId = _preferenceService.Get<string>(CurrentUserKey);
        if (string.IsNullOrEmpty(userId))
        {
            return null;
        }
        
        // If not in local database, try to get from API
        try
        {
            var token = _preferenceService.Get<string>(TokenKey);
            if (string.IsNullOrEmpty(token))
            {
                return null;
            }
            
            var client = _httpClientFactory.CreateClient("SkilledApi");
            client.DefaultRequestHeaders.Authorization = new System.Net.Http.Headers.AuthenticationHeaderValue("Bearer", token);
            
            var response = await client.GetAsync($"{ApiBaseUrl}/users/me");
            if (response.IsSuccessStatusCode)
            {
                var userFromApi = await response.Content.ReadFromJsonAsync<User>();
                if (userFromApi != null)
                {
                    return userFromApi;
                }
            }
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error getting user from API");
        }
        
        return null;
    }

    /// <summary>
    /// Logs in a user with the provided email and password.
    /// </summary>
    /// <param name="email"></param>
    /// <param name="password"></param>
    /// <returns></returns>
    public async Task<bool> LoginAsync(string email, string password)
    {
        try
        {
            // First check local database
            var user = await GetCurrentUserAsync();
            
            if (user != null)
            {
                // Using direct API connection for authentication
                var client = _httpClientFactory.CreateClient("SkilledApi");
                var content = new
                {
                    email,
                    password
                };
                
                var response = await client.PostAsJsonAsync($"{ApiBaseUrl}/auth/login", content);
                if (response.IsSuccessStatusCode)
                {
                    var authResponse = await response.Content.ReadFromJsonAsync<AuthResponse>();
                    if (authResponse != null)
                    {
                        _preferenceService.Set(TokenKey, authResponse.Token);
                        _preferenceService.Set(RefreshTokenKey, authResponse.RefreshToken);
                        _preferenceService.Set(CurrentUserKey, authResponse.User.Id);
                        
                        return true;
                    }
                }
            }
            
            return false;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error during login");
            return false;
        }
    }

    /// <summary>
    /// Registers a new user with the provided details.
    /// </summary>
    /// <param name="firstName"></param>
    /// <param name="lastName"></param>
    /// <param name="email"></param>
    /// <param name="password"></param>
    /// <param name="role"></param>
    /// <returns></returns>
    public async Task<bool> RegisterAsync(string firstName, string lastName, string email, string password, UserRole role)
    {
        try
        {
            // Check if user exists first
            var user = await GetCurrentUserAsync();
            
            if (user != null)
            {
                return false; // User already exists
            }
            
            // Using direct API connection for registration
            var client = _httpClientFactory.CreateClient("SkilledApi");
            var content = new
            {
                firstName,
                lastName,
                email,
                password,
                role = role.ToString()
            };
            
            var response = await client.PostAsJsonAsync($"{ApiBaseUrl}/auth/register", content);
            if (response.IsSuccessStatusCode)
            {
                var authResponse = await response.Content.ReadFromJsonAsync<AuthResponse>();
                if (authResponse != null)
                {
                    _preferenceService.Set(TokenKey, authResponse.Token);
                    _preferenceService.Set(RefreshTokenKey, authResponse.RefreshToken);
                    _preferenceService.Set(CurrentUserKey, authResponse.User.Id);
                    
                    return true;
                }
            }
            
            return false;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error during registration");
            return false;
        }
    }

    /// <summary>
    /// Logs out the currently authenticated user by clearing local tokens and calling the API to invalidate the session.
    /// </summary>
    /// <returns></returns>
    public async Task<bool> LogoutAsync()
    {
        try
        {
            var token = _preferenceService.Get<string>(TokenKey);
            if (!string.IsNullOrEmpty(token))
            {
                // Call API to logout
                var client = _httpClientFactory.CreateClient("SkilledApi");
                client.DefaultRequestHeaders.Authorization = new System.Net.Http.Headers.AuthenticationHeaderValue("Bearer", token);
                
                try
                {
                    await client.PostAsync($"{ApiBaseUrl}/auth/logout", null);
                }
                catch (Exception ex)
                {
                    _logger.LogWarning(ex, "Error calling logout API, continuing with local logout");
                }
            }
            
            // Clear local tokens and user data
            _preferenceService.Remove(TokenKey);
            _preferenceService.Remove(RefreshTokenKey);
            _preferenceService.Remove(CurrentUserKey);
            
            return true;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error during logout");
            return false;
        }
    }

    /// <summary>
    /// Checks if the user is authenticated by validating the token stored in preferences.
    /// </summary>
    /// <returns></returns>
    public async Task<bool> IsAuthenticatedAsync()
    {
        var token = _preferenceService.Get<string>(TokenKey);
        if (string.IsNullOrEmpty(token))
        {
            return false;
        }
        
        // Validate token
        var tokenHandler = new JwtSecurityTokenHandler();
        try
        {
            var jwtToken = tokenHandler.ReadJwtToken(token);
            var expiry = jwtToken.ValidTo;
            
            if (expiry < DateTime.UtcNow)
            {
                // Token expired, try to refresh
                return await RefreshTokenAsync();
            }
            
            return true;
        }
        catch
        {
            return false;
        }
    }
    
    private async Task<bool> RefreshTokenAsync()
    {
        var refreshToken = _preferenceService.Get<string>(RefreshTokenKey);
        if (string.IsNullOrEmpty(refreshToken))
        {
            return false;
        }
        
        try
        {
            var client = _httpClientFactory.CreateClient("SkilledApi");
            var content = new
            {
                refreshToken
            };
            
            var response = await client.PostAsJsonAsync($"{ApiBaseUrl}/auth/refresh", content);
            if (response.IsSuccessStatusCode)
            {
                var authResponse = await response.Content.ReadFromJsonAsync<AuthResponse>();
                if (authResponse != null)
                {
                    _preferenceService.Set(TokenKey, authResponse.Token);
                    _preferenceService.Set(RefreshTokenKey, authResponse.RefreshToken);
                    
                    return true;
                }
            }
            
            return false;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error refreshing token");
            return false;
        }
    }

    /// <summary>
    /// Resets the password for the user with the provided email by calling the API endpoint.
    /// </summary>
    /// <param name="email"></param>
    /// <returns></returns>
    public async Task<bool> ResetPasswordAsync(string email)
    {
        try
        {
            var client = _httpClientFactory.CreateClient("SkilledApi");
            var content = new
            {
                email
            };
            
            var response = await client.PostAsJsonAsync($"{ApiBaseUrl}/auth/reset-password", content);
            return response.IsSuccessStatusCode;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error resetting password");
            return false;
        }
    }

    /// <summary>
    /// Updates the user profile with the provided user details.
    /// </summary>
    /// <param name="user"></param>
    /// <returns></returns>
    public async Task<bool> UpdateUserProfileAsync(User user)
    {
        try
        {
            var token = _preferenceService.Get<string>(TokenKey);
            if (string.IsNullOrEmpty(token))
            {
                return false;
            }
            
            var client = _httpClientFactory.CreateClient("SkilledApi");
            client.DefaultRequestHeaders.Authorization = new System.Net.Http.Headers.AuthenticationHeaderValue("Bearer", token);
            
            var response = await client.PutAsJsonAsync($"{ApiBaseUrl}/users/{user.Id}", user);
            if (response.IsSuccessStatusCode)
            {
                var updatedUser = await response.Content.ReadFromJsonAsync<User>();
                if (updatedUser != null)
                {
                    return true;
                }
            }
            
            return false;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error updating user profile");
            return false;
        }
    }
}

/// <summary>
/// Represents the response from the authentication API containing tokens and user information.
/// </summary>
public class AuthResponse
{
    public string Token { get; set; }
    public string RefreshToken { get; set; }
    public User User { get; set; }
}