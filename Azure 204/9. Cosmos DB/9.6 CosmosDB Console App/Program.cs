using Microsoft.Azure.Cosmos;
using Microsoft.Azure.Cosmos.Linq;
using System.Collections.ObjectModel;


// See https://aka.ms/new-console-template for more information
Console.WriteLine("Hello, World!");


var client = new CosmosClient("AccountEndpoint=https://az-demo-0905-nosql.documents.azure.com:443/;AccountKey=ezu5A2S3TI2PVHc3Qyo1tVIfYLVFclhHRN3TEQBl8I19XsAhAK0ueJcY2NL2F0VXfwSU7jdzvTpFACDbDUIuwA==;");
var container = client.GetDatabase("az-demo-0905-database").GetContainer("az-demo-0905-container");
var queryable = container.GetItemLinqQueryable<MyData>();
using FeedIterator<MyData> feed = queryable.OrderBy(x => x.name).ToFeedIterator();

while(feed.HasMoreResults){
    var response = await feed.ReadNextAsync();
    foreach(MyData item in response)
    {
        Console.WriteLine("id:[{0}] name:[{1}] description:[{2}]", item.id, item.name, item.description);
    }
}