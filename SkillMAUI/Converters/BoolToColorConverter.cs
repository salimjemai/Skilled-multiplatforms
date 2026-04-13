using System.Globalization;

namespace Skilled.Converters;

/// <summary>
/// Converts a bool to a Color.
/// true  → primary brand color (#512BD4)
/// false → muted/inactive color (#AAAAAA)
///
/// Optional ConverterParameter can override the "true" color string, e.g.
///   Converter={StaticResource BoolToColorConverter}, ConverterParameter='#E91E63'
/// </summary>
public class BoolToColorConverter : IValueConverter
{
    public object? Convert(object? value, Type targetType, object? parameter, CultureInfo culture)
    {
        bool flag = value is bool b && b;

        if (flag)
        {
            // Allow caller to override the active colour via ConverterParameter
            if (parameter is string colorStr && !string.IsNullOrWhiteSpace(colorStr))
            {
                return Color.FromArgb(colorStr);
            }
            return Color.FromArgb("#512BD4"); // Skilled brand purple
        }

        return Color.FromArgb("#AAAAAA"); // inactive grey
    }

    public object? ConvertBack(object? value, Type targetType, object? parameter, CultureInfo culture)
    {
        throw new NotImplementedException();
    }
}
