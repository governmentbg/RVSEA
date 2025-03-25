using Microsoft.Extensions.Configuration;
using System.Configuration;

[assembly: System.Reflection.AssemblyVersion("1.2.*")]
namespace DAA.App.FileUpload
{
    internal static class Program
    {
        public static IConfiguration Configuration = null!;

        /// <summary>
        ///  The main entry point for the application.
        /// </summary>
        [STAThread]
        static void Main()
        {
            // To customize application configuration such as set high DPI settings or default font,
            // see https://aka.ms/applicationconfiguration

            //var builder = new ConfigurationBuilder().AddJsonFile("appsettings.json", optional: false, reloadOnChange: true);
            //Configuration = builder.Build();


            Application.ThreadException += HandleAll;
            //AppDomain.CurrentDomain.UnhandledException += ExceptionHandler;
            Application.SetUnhandledExceptionMode(UnhandledExceptionMode.CatchException);

            Application.SetHighDpiMode(HighDpiMode.SystemAware);
            Application.EnableVisualStyles();
            Application.SetCompatibleTextRenderingDefault(false);

            ApplicationConfiguration.Initialize();
            Application.Run(new MainForm());
        }

        public static void ExceptionHandler(object sender, UnhandledExceptionEventArgs e)
        {
            Exception? exception = e?.ExceptionObject as Exception;
            if (exception != null)
            {
                MessageBox.Show(exception.Message, "DAA.App.FileUpload", MessageBoxButtons.OK, MessageBoxIcon.Error);
            }
        }

        private static void HandleAll(object sender, System.Threading.ThreadExceptionEventArgs e)
        {
            Exception? exception = e?.Exception;
            if (exception != null)
            {
                MessageBox.Show(exception.Message + " " + exception.StackTrace, "DAA.App.FileUpload", MessageBoxButtons.OK, MessageBoxIcon.Error);
            }
        }
    }
}