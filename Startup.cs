using ContosoUniversity.Data;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Hosting;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Logging;
using EFLogging;

namespace ContosoUniversity
{
    public class LoggingEvents
    {
        public const int CONFIGURATION = 1000;
    }
    public class Startup
    {
        private readonly ILogger _logger;

        public Startup(IHostingEnvironment env, ILoggerFactory loggerFactory, ILogger<Startup> logger)
        {
            var builder = new ConfigurationBuilder()
                .SetBasePath(env.ContentRootPath)
                .AddJsonFile("appsettings.json", optional: false, reloadOnChange: true)
                .AddJsonFile($"appsettings.{env.EnvironmentName}.json", optional: true)
                .AddEnvironmentVariables();
            Configuration = builder.Build();
            loggerFactory
                .AddConsole()
                .AddDebug();
            _logger = logger;

            foreach (var envVar in Configuration.GetChildren())
            {
                _logger.LogInformation(LoggingEvents.CONFIGURATION, $"{envVar.Key}: {envVar.Value}");
            }
        }

        public IConfigurationRoot Configuration { get; }

        // This method gets called by the runtime. Use this method to add services to the container.
        public void ConfigureServices(IServiceCollection services)
        {
            var dbHost = $"{Configuration["DATABASE_SERVICE_HOST"]}";
            _logger.LogInformation(LoggingEvents.CONFIGURATION, dbHost);
            var dbDatabase = $"{Configuration["MSSQL_DATABASE"]}";
            _logger.LogInformation(LoggingEvents.CONFIGURATION, dbDatabase);
            var dbUser = $"{Configuration["MSSQL_USER"]}";
            _logger.LogInformation(LoggingEvents.CONFIGURATION, dbUser);
            var dbPassword = $"{Configuration["MSSQL_PASSWORD"]}";
            _logger.LogInformation(LoggingEvents.CONFIGURATION, dbPassword);

            //var connectionString = Configuration.GetConnectionString("DefaultConnection");
            var connectionString = $"Server={dbHost};Database={dbDatabase};User Id={dbUser};Password={dbPassword}";

            _logger.LogInformation(LoggingEvents.CONFIGURATION, "connectionString={connectionString}", connectionString);

            // Add framework services.
            services.AddDbContext<SchoolContext>(options =>
                options.UseSqlServer(connectionString));

            services.AddMvc();
        }

        // This method gets called by the runtime. Use this method to configure the HTTP request pipeline.
        public void Configure(IApplicationBuilder app, IHostingEnvironment env, ILoggerFactory loggerFactory, SchoolContext context)
        {
            // TODO wrap this in a guard so that it only happens on Dev not Prod nor test
            // https://docs.microsoft.com/en-us/ef/core/miscellaneous/logging
            loggerFactory.AddProvider(new MyLoggerProvider());

            loggerFactory.AddConsole(Configuration.GetSection("Logging"));
            loggerFactory.AddDebug();

            if (env.IsDevelopment())
            {
                app.UseDeveloperExceptionPage();
                app.UseBrowserLink();
            }
            else
            {
                app.UseExceptionHandler("/Home/Error");
            }

            app.UseStaticFiles();

            app.UseMvc(routes =>
            {
                routes.MapRoute(
                    name: "default",
                    template: "{controller=Home}/{action=Index}/{id?}");
            });

            DbInitializer.Initialize(context);
        }
    }
}
