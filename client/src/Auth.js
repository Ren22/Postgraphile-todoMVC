import auth0 from "auth0-js";
import Cookies from "js-cookie";

class Auth {
  auth0 = new auth0.WebAuth({
    domain: process.env.REACT_APP_AUTH0_DOMAIN,
    clientID: process.env.REACT_APP_AUTH0_CLIENT_ID,
    redirectUri: "http://localhost:3000/",
    responseType: "token id_token",
    scope: "openid",
    audience: process.env.REACT_APP_AUTH0_AUDIENCE,
  });

  constructor() {
    if (/access_token|id_token|error/.test(window.location.hash)) {
      this.handleAuthentication();
    } else if (localStorage.getItem("isLoggedIn") === "true") {
      this.renewSession();
    } else {
      this.login();
    }
  }

  handleAuthentication = () => {
    this.auth0.parseHash((err, authResult) => {
      if (authResult && authResult.accessToken && authResult.idToken) {
        this.setSession(authResult);
      } else if (err) {
        console.error("handleAuthentication", err);
        window.history.pushState({}, "", "/");
      }
    });
  };

  setSession = authResult => {
    // Set isLoggedIn flag in localStorage
    localStorage.setItem("isLoggedIn", "true");

    // Set the time that the access token will expire at
    let expiresAt = authResult.expiresIn * 1000 + new Date().getTime();
    this.accessToken = authResult.accessToken;
    this.idToken = authResult.idToken;
    this.expiresAt = expiresAt;

    Cookies.set("token", authResult.accessToken, {
      expires: authResult.expiresIn / 60 / 60 / 24,
    });

    window.history.pushState({}, "", "/");
  };

  renewSession = () => {
    this.auth0.checkSession({}, (err, authResult) => {
      if (authResult && authResult.accessToken && authResult.idToken) {
        this.setSession(authResult);
      } else if (err) {
        console.error(err);

        setTimeout(() => {
          this.login();
        }, 1000);
      }
    });
  };

  logout = () => {
    // Remove tokens and expiry time
    this.accessToken = null;
    this.idToken = null;
    this.expiresAt = 0;

    // Remove isLoggedIn flag from localStorage
    localStorage.removeItem("isLoggedIn");
    Cookies.remove("token");

    window.history.pushState({}, "", "/");
  };

  isAuthenticated = () => {
    // Check whether the current time is past the
    // access token's expiry time
    let expiresAt = this.expiresAt;
    return new Date().getTime() < expiresAt;
  };

  login = () => {
    this.auth0.authorize();
  };
}

export default new Auth();
