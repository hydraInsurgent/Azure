using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;
using Microsoft.Azure.Cosmos;
using Microsoft.Azure.Cosmos.Linq;
using System.Collections.ObjectModel;


namespace _9._CosmosDB.Pages;

public class IndexModel : PageModel
{
    private readonly ILogger<IndexModel> _logger;

    public IndexModel(ILogger<IndexModel> logger)
    {
        _logger = logger;
    }

    public async Task OnGet()
    {
        var client = new CosmosClient("AccountEndpoint=https://az-demo-0905-nosql.documents.azure.com:443/;AccountKey=ezu5A2S3TI2PVHc3Qyo1tVIfYLVFclhHRN3TEQBl8I19XsAhAK0ueJcY2NL2F0VXfwSU7jdzvTpFACDbDUIuwA==;");
        var container = client.GetDatabase("az-demo-0905-database").GetContainer("az-demo-0905-container");
        var queryable = container.GetItemLinqQueryable<MyData>();
        var results = new List<MyData>();
        using FeedIterator<MyData> feed = queryable.OrderBy(x =>x.name).ToFeedIterator();
        while(feed.HasMoreResults){
            var response = await feed.ReadNextAsync();
            foreach(MyData item in response){
                results.Add(item);
            }
        }

        ViewData.Add("Data",results);

    }
}

public record MyData(string id, string name, string description);