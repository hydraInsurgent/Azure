using System.Reflection.Metadata;
using Azure.Identity;
using Azure.Storage.Blobs;

string userAssignedClientId = "b873163f-214a-43ed-b50c-7c647fec570a";
var credential = new DefaultAzureCredential(new DefaultAzureCredentialOptions { TenantId = "c9149790-4958-488a-ae47-c6f99abd0eb3", ManagedIdentityClientId = userAssignedClientId });


BlobServiceClient GetBlobServiceClient(string accountName)
    => new(new Uri($"https://{accountName}.blob.core.windows.net"), credential);

BlobContainerClient GetBlobContainer(BlobServiceClient client, string containerName)
    => client.GetBlobContainerClient(containerName);


BlobClient GetBlobClient(BlobContainerClient container, string fileName)
    => container.GetBlobClient(Path.GetFileName(fileName));

void ListBlobs(BlobContainerClient container){
    var blobs = container.GetBlobs();
    foreach (var blob in blobs){
        Console.WriteLine($"Blob name: {blob.Name}");
    }
    {
        
    }
}

// See https://aka.ms/new-console-template for more information
Console.WriteLine("Hello, World!");

var client = GetBlobServiceClient("azdemo1102as");
Console.WriteLine($"Account URI : {client.Uri}");


var container = GetBlobContainer(client, "new-images");
Console.WriteLine($"Container URI : {container.Uri}");

var metadata = new Dictionary<string, string>{
    { "dotType", "textDocuments" },
    { "category", "guidance" }
};

await container.SetMetadataAsync(metadata);

var containerProperties = await container.GetPropertiesAsync();
Console.WriteLine($"Container access level : {containerProperties.Value.PublicAccess}");
Console.WriteLine($"Container last modified : {containerProperties.Value.LastModified}");

foreach(var metadataItem in containerProperties.Value.Metadata){
    Console.WriteLine($"Key: {metadataItem.Key}\t Value: {metadataItem.Value}");
}

// Uploads out blob
var blob = GetBlobClient(container, "./dummy.txt");
await blob.UploadAsync("./dummy.txt",true);

// Lists our blob items.
ListBlobs(container);

// Download our blob.
await blob.DownloadToAsync("./dummy2.txt");

// Delete our blob.
await blob.DeleteIfExistsAsync();

ListBlobs(container);