﻿using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Globalization;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Alba.CsConsoleFormat;
using McMaster.Extensions.CommandLineUtils;
using Org.BouncyCastle.Crypto;
using Org.BouncyCastle.OpenSsl;
using Org.BouncyCastle.Pkcs;
using Org.BouncyCastle.Security;
using Org.BouncyCastle.X509;
using QBittorrent.Client;
using QBittorrent.CommandLineInterface.ViewModels.ServerPreferences;

namespace QBittorrent.CommandLineInterface.Commands
{
    public partial class ServerCommand
    {
        [Subcommand(typeof(WebInterface))]
        public partial class Settings
        {
            [Command("web", Description = "Manages web UI and API settings.", ExtendedHelpText = ExtendedHelp)]
            public class WebInterface : SettingsCommand<WebInterfaceViewModel>
            {
                private string _certificate;
                private string _key;

                [Option("-l|--lang <LANGUAGE>", "Web UI language", CommandOptionType.SingleValue)]
                [MinLength(2)]
                public string Locale { get; set; }

                [Option("-a|--address <ADDRESS>", "Web interface address. Pass empty string to listen on any address.", CommandOptionType.SingleValue)]
                public string WebUIAddress { get; set; }

                [Option("-p|--port <PORT>", "Web interface port", CommandOptionType.SingleValue)]
                [Range(1, 65535)]
                public int? WebUIPort { get; set; }

                [Option("-d|--domain <DOMAIN>", "Web interface domain. Pass empty string to listen on any domain.", CommandOptionType.SingleValue)]
                public string WebUIDomain { get; set; }

                [Option("-u|--upnp <BOOL>", "Use UPnP/NAT-PMP", CommandOptionType.SingleValue)]
                public bool? WebUIUpnp { get; set; }

                [Option("-s|--https <BOOL>", "Use HTTPS", CommandOptionType.SingleValue)]
                public bool? WebUIHttps { get; set; }

                [Option("-c|--cert <PATH>",
                    "X509 certificate path on the client machine. The certificate can be in PEM (.pem, .crt, .cer) format. For qBittorrent before 4.2.",
                    CommandOptionType.SingleValue)]
                [FileExists]
                [NoAutoSet]
                [MaxApiVersion("2.3.0", "--cert option cannot be used with qBittorrent 4.2.0 or later. Use --cert-path option instead.")]
                public string CertificatePath { get; set; }

                [Option("-k|--key <PATH>",
                    "X509 certificate key path on the client machine. The key must be in PEM (.key) format without encryption. For qBittorrent before 4.2.",
                    CommandOptionType.SingleValue)]
                [FileExists]
                [NoAutoSet]
                [MaxApiVersion("2.3.0", "--key option cannot be used with qBittorrent 4.2.0 or later. Use --key-path option instead.")]
                public string CertificateKeyPath { get; set; }

                [Option("-P|--key-password <PASSWORD>", "X509 certificate key password.", CommandOptionType.SingleValue)]
                [NoAutoSet]
                public string CertificateKeyPassword { get; set; }

                [Option("-C|--cert-path <PATH>", 
                    "X509 certificate path on the server machine. The certificate can be in PEM (.pem, .crt, .cer) format. For qBittorrent 4.2 or later.",
                    CommandOptionType.SingleValue)]
                [MinApiVersion("2.3.0", "--cert-path option requires qBittorrent 4.2.0 or later. Use --cert option instead.")]
                public string WebUISslCertificatePath { get; set; }

                [Option("-K|--key-path <PATH>",
                    "X509 certificate path on the server machine. The key must be in PEM (.key) format without encryption. For qBittorrent 4.2 or later.",
                    CommandOptionType.SingleValue)]
                [MinApiVersion("2.3.0", "--key-path option requires qBittorrent 4.2.0 or later. Use --key option instead.")]
                public string WebUISslKeyPath { get; set; }

                [Option("-A|--alt-ui <BOOL>", "Enables/Disables alternative web UI. Requires qBittorrent 4.1.5 or later.", CommandOptionType.SingleValue)]
                [MinApiVersion("2.2.0", "Alternative Web UI requires qBittorrent 4.1.5 or later.")]
                public bool? AlternativeWebUIEnabled { get; set; }

                [Option("-U|--alt-ui-path <PATH>", "Alternative web UI path. Requires qBittorrent 4.1.5 or later.", CommandOptionType.SingleValue)]
                [MinApiVersion("2.2.0", "Alternative Web UI requires qBittorrent 4.1.5 or later.")]
                public string AlternativeWebUIPath { get; set; }

                [Option("-S|--secure-cookie <BOOL>", 
                    "Set Secure attribute on cookie when using HTTPS. Requires qBittorrent 4.2.2 or later.", 
                    CommandOptionType.SingleValue)]
                [MinApiVersion("2.4.1", "--secure-cookie option requires qBittorrent 4.2.2 or later.")]
                public bool? WebUISecureCookie { get; set; }

                [Option("-m|--max-auth-failures <NUMBER>",
                    "The number of the failed authentication attempts after which the client will be banned. Requires qBittorrent 4.2.2 or later.",
                    CommandOptionType.SingleValue)]
                [MinApiVersion("2.4.1", "--secure-cookie option requires qBittorrent 4.2.2 or later.")]
                public int? WebUIMaxAuthenticationFailures { get; set; }

                [Option("-b|--ban-duration <SECONDS>",
                    "The duration (in seconds) the client will be banned for after the specified in --max-auth-failures number of failed authentication attempts." +
                    " Requires qBittorrent 4.2.2 or later.",
                    CommandOptionType.SingleValue)]
                [MinApiVersion("2.4.1", "--secure-cookie option requires qBittorrent 4.2.2 or later.")]
                public int? WebUIBanDuration { get; set; }

                [Option("-e|--use-custom-http-headers <BOOL>",
                    "Enable or disables custom HTTP headers for Web UI. Requires qBittorrent 4.2.5 or later.",
                    CommandOptionType.SingleValue)]
                [MinApiVersion("2.5.1", "--secure-cookie option requires qBittorrent 4.2.5 or later.")]
                public bool? WebUICustomHttpHeadersEnabled { get; set; }
                
                [Option("-H|--custom-http-header <HEADER>",
                    "Custom HTTP header for Web UI. Use a colon (:) as a separator between header name and value. " +
                    "This option can be repeated in order to set several headers. " +
                    "Requires qBittorrent 4.2.5 or later.",
                    CommandOptionType.MultipleValue)]
                [MinApiVersion("2.5.1", "--secure-cookie option requires qBittorrent 4.2.5 or later.")]
                public IList<string> WebUICustomHttpHeaders { get; set; }

                protected override async Task Prepare(QBittorrentClient client, CommandLineApplication app, IConsole console)
                {
                    if (WebUIAddress?.Trim() == string.Empty)
                    {
                        WebUIAddress = "*";
                    }

                    if (WebUIDomain?.Trim() == string.Empty)
                    {
                        WebUIDomain = "*";
                    }

                    switch (GetCertificateFileType())
                    {
                        case CertificateFileType.Pem:
                            if (CertificateKeyPath == null)
                                throw new InvalidOperationException("--key option is required if certificate file has PEM format.");
                            _certificate = ReadPemCertificates();
                            _key = ReadPemKeys(GetPasswordFinder());
                            break;
                        case CertificateFileType.Pfx:
                            if (CertificateKeyPath != null)
                                throw new InvalidOperationException("--key option must not be set if certificate file has PKCS #12 format.");
                            (_certificate, _key) = TransformPfx(GetPasswordFinder());
                            break;
                    }

                    IPasswordFinder GetPasswordFinder() => CertificateKeyPassword != null
                        ? new PredefinedPasswordFinder(CertificateKeyPassword)
                        : (IPasswordFinder)new ConsolePasswordFinder(console);
                }

                protected override IReadOnlyDictionary<string, Func<object, object>> CustomFormatters => 
                    new Dictionary<string, Func<object, object>>
                    {
                        [nameof(WebInterfaceViewModel.Locale)] = FormatLanguage,
                        [nameof(WebInterfaceViewModel.WebUISslCertificate)] = FormatCertificate,
                        [nameof(WebInterfaceViewModel.WebUICustomHttpHeaders)] = FormatCustomHttpHeaders
                    };

                private string FormatLanguage(object arg)
                {
                    if (!(arg is string name)) return null;

                    try
                    {
                        var englishName = CultureInfo.GetCultureInfo(name.Replace('_', '-')).EnglishName;
                        return $"{name} ({englishName})";
                    }
                    catch
                    {
                        return null;
                    }
                }

                private object FormatCertificate(object arg)
                {
                    if (arg == null) return null;

                    var memoryStream = new MemoryStream(Encoding.ASCII.GetBytes((string)arg));
                    var certs = ReadPemObjects<X509Certificate>(new StreamReader(memoryStream));

                    var stack = new Stack(certs.Select(cert => new Grid
                    {
                        Stroke = new LineThickness(LineWidth.Single),
                        Columns = { UIHelper.FieldsColumns },
                        Children =
                        {
                            UIHelper.Row("Serial number", cert.SerialNumber),
                            UIHelper.Row("Signature algorithm", cert.SigAlgName),
                            UIHelper.Row("Issuer", cert.IssuerDN),
                            UIHelper.Row("Valid from", cert.NotBefore),
                            UIHelper.Row("Valid to", cert.NotAfter),
                            UIHelper.Row("Subject", cert.SubjectDN)
                        }
                    }).ToArray<object>());
                    return stack;
                }

                private object FormatCustomHttpHeaders(object arg)
                {
                    if (arg is not IList<string> headers) return null;
                    return string.Join(Environment.NewLine, headers);
                }

                protected override void CustomFillPreferences(Preferences preferences)
                {
                    if (_certificate != null)
                    {
                        preferences.WebUISslCertificate = _certificate;
                    }

                    if (_key != null)
                    {
                        preferences.WebUISslKey = _key;
                    }
                }

                #region Certificate file manipulations

                private string ReadPemCertificates()
                {
                    // Validate
                    if (!ReadPemObjects<X509Certificate>(CertificatePath).Any())
                        throw new InvalidOperationException($"The file \"{CertificatePath}\" contains no certificates or has unsupported format.");

                    var certificate = File.ReadAllText(CertificatePath, Encoding.ASCII);
                    return certificate;
                }

                private string ReadPemKeys(IPasswordFinder passwordFinder)
                {
                    try
                    {
                        if (!ReadPrivateKeys(null).Any())
                            throw new InvalidOperationException($"The file \"{CertificateKeyPath}\" contains no private keys or has unsupported format.");

                        var key = File.ReadAllText(CertificateKeyPath, Encoding.ASCII);
                        return key;
                    }
                    catch (PasswordException)
                    {
                        var privateKeys = ReadPrivateKeys(passwordFinder).ToList();
                        if (!privateKeys.Any())
                            throw new InvalidOperationException($"The file \"{CertificateKeyPath}\" contains no private keys.");

                        return WritePrivateKeys(privateKeys);
                    }

                    
                    IEnumerable<AsymmetricKeyParameter> ReadPrivateKeys(IPasswordFinder pf)
                    {
                        using (var input = File.OpenText(CertificateKeyPath))
                        {
                            var reader = new PemReader(input, pf);
                            do
                            {
                                var obj = reader.ReadObject();
                                if (obj is AsymmetricKeyParameter key && key.IsPrivate)
                                    yield return key;
                                else if (obj is AsymmetricCipherKeyPair pair)
                                    yield return pair.Private;
                            } while (!input.EndOfStream);
                        }
                    }

                    string WritePrivateKeys(IEnumerable<AsymmetricKeyParameter> keys)
                    {
                        var result = new StringBuilder();
                        var writer = new PemWriter(new StringWriter(result));
                        foreach (var key in keys)
                        {
                            writer.WriteObject(key);
                        }
                        return result.ToString();
                    }
                }

                private IEnumerable<T> ReadPemObjects<T>(StreamReader input, IPasswordFinder passwordFinder = null)
                { 
                    var reader = new PemReader(input, passwordFinder);
                    do
                    {
                        var obj = reader.ReadObject();
                        if (obj is T t)
                            yield return t;
                    } while (!input.EndOfStream);
                }

                private IEnumerable<T> ReadPemObjects<T>(string path, IPasswordFinder passwordFinder = null)
                {
                    using (var input = File.OpenText(path))
                    {
                        foreach (var obj in ReadPemObjects<T>(input, passwordFinder))
                        {
                            yield return obj;
                        }
                    }
                }

                private (string certificate, string key) TransformPfx(IPasswordFinder passwordFinder)
                {
                    var certOutput = new StringWriter();
                    var keyOutput = new StringWriter();

                    using (var input = File.OpenRead(CertificatePath))
                    {
                        var certWriter = new PemWriter(certOutput);
                        var keyWriter = new PemWriter(keyOutput);
                        var store = new Pkcs12Store(input, passwordFinder.GetPassword());
                        foreach (string alias in store.Aliases)
                        {
                            var cert = store.GetCertificate(alias);
                            if (cert != null)
                            {
                                certWriter.WriteObject(cert.Certificate);
                            }

                            var key = store.GetKey(alias);
                            if (key != null && key.Key.IsPrivate)
                            {
                                keyWriter.WriteObject(key.Key);
                            }
                        }
                    }

                    return (certOutput.ToString(), keyOutput.ToString());
                }

                private CertificateFileType GetCertificateFileType()
                {
                    if (CertificatePath == null)
                        return CertificateFileType.None;

                    var ext = Path.GetExtension(CertificatePath).ToLowerInvariant();
                    return (ext == ".pfx" || ext == ".p12")
                        ? CertificateFileType.Pfx
                        : CertificateFileType.Pem;
                }

                private enum CertificateFileType
                {
                    None,
                    Pem,
                    Pfx
                }

                private class PredefinedPasswordFinder : IPasswordFinder
                {
                    private readonly string _password;

                    public PredefinedPasswordFinder(string password) => _password = password;

                    public char[] GetPassword() => _password.ToCharArray();
                }

                private class ConsolePasswordFinder : IPasswordFinder
                {
                    private readonly IConsole _console;

                    public ConsolePasswordFinder(IConsole console) => _console = console;

                    public char[] GetPassword() => _console.IsInputRedirected
                        ? _console.In.ReadLine()?.ToCharArray()
                        : Prompt.GetPassword("Private key password:")?.ToCharArray();
                }

                #endregion
            }
        }
    }
}
