// Please see documentation at https://docs.microsoft.com/aspnet/core/client-side/bundling-and-minification
// for details on configuring this project to bundle and minify static web assets.

// Write your JavaScript code.
const authConfig = {
    auth:
    {
        clientId: 'ad3fc3cb-933d-468d-bbc0-eee131c69772',
        authority: 'https://login.microsoftonline.com/c9149790-4958-488a-ae47-c6f99abd0eb3'
    }
};

// This will connect us to Azure.
const msalInstance = new Msal.UserAgentApplication(authConfig)

function signIn() {
    // This will popup the login popup
    msalInstance.loginPopup({ scopes: ["user.read"] })
        .then(() => {
            msalInstance  // Once user is logged in it will get the access token silently
                .acquireTokenSilent({ scopes: ["user.read"] })
                .then(function (tokenResponse) {
                    callApi(tokenResponse.accessToken);  // We send the authtoken to the api call on behalf of user.
                })
        })
}

function signOut() {
    msalInstance.logout()
}

// API call 
function callApi(accessToken) {
    var headers = new Headers();
    var bearer = "Bearer " + accessToken;  // for authorization we need to send token like this.
    headers.append("Authorization", bearer);
    var options = {
        method: "GET",
        headers: headers
    };
    var graphEndpoint = "https://graph.microsoft.com/v1.0/me";

    fetch(graphEndpoint, options)
        .then(response => response.json())
        .then(json => {
            let profileElement = document.getElementById('profile');
            profileElement.value = JSON.stringify(json, null, 4)
        })
}