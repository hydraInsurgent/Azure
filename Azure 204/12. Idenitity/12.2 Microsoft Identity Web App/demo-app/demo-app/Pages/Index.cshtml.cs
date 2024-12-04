using Microsoft.AspNetCore.Mvc.RazorPages;
using Microsoft.Identity.Web;
using System.Text.Json;

namespace demo_app.Pages
{
    [AuthorizeForScopes(ScopeKeySection = "DemoApiCall:Scopes")]
    public class IndexModel : PageModel
    {
        private readonly ILogger<IndexModel> _logger;

        private readonly IDownstreamWebApi _downstreamWebApi;

        public IndexModel(ILogger<IndexModel> logger,
                        IDownstreamWebApi downstreamWebApi)
        {
            _logger = logger;
            _downstreamWebApi = downstreamWebApi;
        }

        public async Task OnGet()
        {
            using var response = await _downstreamWebApi.CallWebApiForUserAsync("DemoApiCall");
            if (response.StatusCode == System.Net.HttpStatusCode.OK)
            {
                var apiResult = await response.Content.ReadFromJsonAsync<JsonDocument>();
                ViewData["ApiResult"] = JsonSerializer.Serialize(apiResult, new JsonSerializerOptions { WriteIndented = true });
            }
        }
    }
}