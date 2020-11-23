﻿using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Alba.CsConsoleFormat;
using McMaster.Extensions.CommandLineUtils;
using QBittorrent.Client;
using QBittorrent.CommandLineInterface.ColorSchemes;

namespace QBittorrent.CommandLineInterface.Commands
{
    [Command(Description = "Manage categories.")]
    [Subcommand(typeof(Add))]
    [Subcommand(typeof(Set))]
    [Subcommand(typeof(Delete))]
    [Subcommand(typeof(List))]
    public class CategoryCommand : ClientRootCommandBase
    {
        [Command("add", "create", Description = "Adds a new category.")]
        public class Add : AuthenticatedCommandBase
        {
            [Argument(0, "<NAME>", "Category name.")]
            [Required]
            public string Name { get; set; }

            [Option("-s|--save-path <PATH>", "The save path for the category. Requires qBittorrent 4.1.3 or later.", CommandOptionType.SingleValue)]
            public string SavePath { get; set; }

            protected override async Task<int> OnExecuteAuthenticatedAsync(QBittorrentClient client, CommandLineApplication app, IConsole console)
            {
                if (!string.IsNullOrEmpty(SavePath))
                {
                    var apiVersion = await client.GetApiVersionAsync();
                    if (apiVersion < new ApiVersion(2, 1))
                    {
                        console.WriteLineColored("The --save-path parameter requires qBittorrent 4.1.3 or later.",
                            ColorScheme.Current.Warning);
                        return ExitCodes.Failure;
                    }

                    await client.AddCategoryAsync(Name, SavePath);
                }
                else
                {
                    await client.AddCategoryAsync(Name);
                }
                return ExitCodes.Success;
            }
        }

        [Command(Description = "Changes category properties. Requires qBittorrent 4.1.3 or later.")]
        public class Set : AuthenticatedCommandBase
        {
            [Argument(0, "<NAME>", "Category name.")]
            [Required]
            public string Name { get; set; }

            [Option("-s|--save-path <PATH>", "The save path for the category. Can be an empty string.", CommandOptionType.SingleValue)]
            [Required(AllowEmptyStrings = true)]
            public string SavePath { get; set; }

            protected override async Task<int> OnExecuteAuthenticatedAsync(QBittorrentClient client, CommandLineApplication app, IConsole console)
            {
                var apiVersion = await client.GetApiVersionAsync();
                if (apiVersion < new ApiVersion(2, 1))
                {
                    console.WriteLineColored("The --save-path parameter requires qBittorrent 4.1.3 or later.",
                        ColorScheme.Current.Warning);
                    return ExitCodes.Failure;
                }

                await client.EditCategoryAsync(Name, SavePath);
                return ExitCodes.Success;
            }
        }

        [Command(Description = "Deletes one or several categories.")]
        public class Delete : AuthenticatedCommandBase
        {
            [Argument(0, "<NAME_1 NAME_2 ... NAME_N>", "The names of categories to delete.")]
            [Required]
            public List<string> Names { get; set; }

            protected override async Task<int> OnExecuteAuthenticatedAsync(QBittorrentClient client, CommandLineApplication app, IConsole console)
            {
                await client.DeleteCategoriesAsync(Names);
                return ExitCodes.Success;
            }
        }

        [Command(Description = "Shows the category list.", ExtendedHelpText = FormatHelpText)]
        public class List : ListCommandBase<Category>
        {
            protected override async Task<int> OnExecuteAuthenticatedAsync(QBittorrentClient client, CommandLineApplication app, IConsole console)
            {
                var apiVersion = await client.GetApiVersionAsync();
                var categories = apiVersion >= new ApiVersion(2, 1, 1)
                    ? await client.GetCategoriesAsync()
                    : (await client.GetPartialDataAsync()).CategoriesChanged;

                Print(categories.Values);
                return ExitCodes.Success;
            }

            protected override void PrintTable(IEnumerable<Category> categories)
            {
                if (categories?.Any() == true)
                {
                    var doc = new Document(
                            new Grid
                            {
                                Columns =
                                {
                                    new Column {Width = GridLength.Auto},
                                    new Column {Width = GridLength.Star(1)}
                                },
                                Children =
                                {
                                    UIHelper.Header("Name"),
                                    UIHelper.Header("Save Path"),
                                    categories.Select(c => new[]
                                    {
                                        new Cell(c.Name),
                                        new Cell(c.SavePath)
                                    })
                                },
                                Stroke = LineThickness.Single
                            })
                        .SetColors(ColorScheme.Current.Normal);
                    ConsoleRenderer.RenderDocument(doc);
                }
            }
        }
    }
}
