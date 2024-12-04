using Azure.Containers.ContainerRegistry;
using Azure.Identity;

// See https://aka.ms/new-console-template for more information
Console.WriteLine("Hello, World!");

var endpoint = new Uri("https://regdemoarm.azurecr.io");
var registry = new ContainerRegistryClient(
    endpoint,
    new AzureCliCredential(),
    new ContainerRegistryClientOptions
    {
        Audience = ContainerRegistryAudience.AzureResourceManagerPublicCloud
    });

Console.WriteLine("Connected to {0}", endpoint);

var repositoryNames = registry.GetRepositoryNamesAsync();
await foreach(var repositoryName in repositoryNames){
    Console.WriteLine("Found repository: {0}", repositoryName);
    var repository = registry.GetRepository(repositoryName);

    var imageManifests = repository.GetAllManifestPropertiesAsync();
    await foreach(var imageManifest in imageManifests){
        Console.WriteLine("   Found image Manifest: {0}", imageManifest);
        var image = repository.GetArtifact(imageManifest.Digest);

        foreach(var tag in imageManifest.Tags){
            Console.WriteLine("      Found YAH: {0}", tag);
        }
    }
}