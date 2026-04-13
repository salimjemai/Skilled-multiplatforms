using Microsoft.Maui.Storage;
using Newtonsoft.Json;

namespace Skilled.Services;

public interface IPreferenceService
{
    T Get<T>(string key, T defaultValue = default);
    void Set<T>(string key, T value);
    void Remove(string key);
    bool ContainsKey(string key);
}

public class PreferenceService : IPreferenceService
{
    public T Get<T>(string key, T defaultValue = default)
    {
        if (Preferences.ContainsKey(key))
        {
            var value = Preferences.Get(key, string.Empty);
            if (string.IsNullOrEmpty(value))
            {
                return defaultValue;
            }

            try
            {
                if (typeof(T) == typeof(string))
                {
                    return (T)(object)value;
                }

                return JsonConvert.DeserializeObject<T>(value);
            }
            catch
            {
                return defaultValue;
            }
        }

        return defaultValue;
    }

    public void Set<T>(string key, T value)
    {
        if (value == null)
        {
            Preferences.Remove(key);
            return;
        }

        if (typeof(T) == typeof(string))
        {
            Preferences.Set(key, value as string);
        }
        else
        {
            var serializedValue = JsonConvert.SerializeObject(value);
            Preferences.Set(key, serializedValue);
        }
    }

    public void Remove(string key)
    {
        Preferences.Remove(key);
    }

    public bool ContainsKey(string key)
    {
        return Preferences.ContainsKey(key);
    }
}