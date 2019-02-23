const jwt = require("jsonwebtoken");
const jwksClient = require("jwks-rsa");
const { promisify } = require("util");

const jwtVerify = promisify(jwt.verify);

const client = jwksClient({
  cache: true,
  jwksUri: process.env.JWKS_URI,
});
function getKey(header, callback) {
  client.getSigningKey(header.kid, function(err, key) {
    if (err) {
      return callback(err);
    }
    var signingKey = key.publicKey || key.rsaPublicKey;
    callback(null, signingKey);
  });
}

module.exports = async function parseClaims(req) {
  const token = req.cookies.token;
  if (!token) {
    throw "No token provided";
  }

  return await jwtVerify(token, getKey, {});
};
