using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Skilled.Migrations
{
    /// <inheritdoc />
    public partial class AddDefaultSchema : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.EnsureSchema(
                name: "skilled_db");

            migrationBuilder.RenameTable(
                name: "Users",
                newName: "Users",
                newSchema: "skilled_db");

            migrationBuilder.RenameTable(
                name: "TradeServices",
                newName: "TradeServices",
                newSchema: "skilled_db");

            migrationBuilder.RenameTable(
                name: "TradeCategories",
                newName: "TradeCategories",
                newSchema: "skilled_db");

            migrationBuilder.RenameTable(
                name: "ServiceProviders",
                newName: "ServiceProviders",
                newSchema: "skilled_db");

            migrationBuilder.RenameTable(
                name: "Reviews",
                newName: "Reviews",
                newSchema: "skilled_db");

            migrationBuilder.RenameTable(
                name: "Payments",
                newName: "Payments",
                newSchema: "skilled_db");

            migrationBuilder.RenameTable(
                name: "Locations",
                newName: "Locations",
                newSchema: "skilled_db");

            migrationBuilder.RenameTable(
                name: "ChatPreviews",
                newName: "ChatPreviews",
                newSchema: "skilled_db");

            migrationBuilder.RenameTable(
                name: "ChatMessages",
                newName: "ChatMessages",
                newSchema: "skilled_db");

            migrationBuilder.RenameTable(
                name: "Bookings",
                newName: "Bookings",
                newSchema: "skilled_db");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.RenameTable(
                name: "Users",
                schema: "skilled_db",
                newName: "Users");

            migrationBuilder.RenameTable(
                name: "TradeServices",
                schema: "skilled_db",
                newName: "TradeServices");

            migrationBuilder.RenameTable(
                name: "TradeCategories",
                schema: "skilled_db",
                newName: "TradeCategories");

            migrationBuilder.RenameTable(
                name: "ServiceProviders",
                schema: "skilled_db",
                newName: "ServiceProviders");

            migrationBuilder.RenameTable(
                name: "Reviews",
                schema: "skilled_db",
                newName: "Reviews");

            migrationBuilder.RenameTable(
                name: "Payments",
                schema: "skilled_db",
                newName: "Payments");

            migrationBuilder.RenameTable(
                name: "Locations",
                schema: "skilled_db",
                newName: "Locations");

            migrationBuilder.RenameTable(
                name: "ChatPreviews",
                schema: "skilled_db",
                newName: "ChatPreviews");

            migrationBuilder.RenameTable(
                name: "ChatMessages",
                schema: "skilled_db",
                newName: "ChatMessages");

            migrationBuilder.RenameTable(
                name: "Bookings",
                schema: "skilled_db",
                newName: "Bookings");
        }
    }
}
