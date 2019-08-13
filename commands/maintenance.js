const http = require('https');

const authEmail = process.env.CLOUDFLARE_AUTH_EMAIL;
const authKey = process.env.CLOUDFLARE_AUTH_KEY;
const zoneId = process.env.CLOUDFLARE_ZONE_ID;
const domain = process.env.CLOUDFLARE_DOMAIN_NAME;
const script = process.env.MAINTENANCE_PAGE;
const pattern = `${domain}/*`;
const hostname = 'api.cloudflare.com';

const allowedCommands = ['enable', 'disable'];
const commands = {
  enable,
  disable,
};

const arguments = process.argv.slice(2);

if (arguments.length !== 1 || allowedCommands.indexOf(arguments[0]) === -1) {
  process.exit(1);
}
const command = arguments[0];

commands[command]()
  .then(() => {
    console.log(`Command "${command}" successfully executed`);
  })
  .catch(error => {
    console.log(error);
    process.exit(1);
  });

function enable() {
  const options = {
    method: 'POST',
    hostname,
    path: `/client/v4/zones/${zoneId}/workers/routes`,
    headers: {
      'x-auth-email': authEmail,
      'x-auth-key': authKey,
      'content-type': 'application/json',
      'cache-control': 'no-cache',
    }
  };

  return sendRequest(options, { pattern, script });
}

async function disable() {
  const routesList = await list();
  for (const route of routesList) {
    if (route.pattern === pattern) {
      const options = {
        method: 'DELETE',
        hostname,
        path: `/client/v4/zones/${zoneId}/workers/routes/${route.id}`,
        headers: {
          'x-auth-email': authEmail,
          'x-auth-key': authKey,
          'cache-control': 'no-cache',
        }
      };

      return sendRequest(options);
    }
  }
}

function list() {
  const options = {
    method: 'GET',
    hostname: hostname,
    path: `/client/v4/zones/${zoneId}/workers/routes`,
    headers: {
      'x-auth-email': authEmail,
      'x-auth-key': authKey,
      'cache-control': 'no-cache',
    }
  };
  return sendRequest(options);
}

function sendRequest(options, body) {
  return new Promise((resolve, reject) => {
    const req = http.request(options, (res) => {
      const chunks = [];

      res.on('data', (chunk) => {
        chunks.push(chunk);
      });

      res.on('end', function () {
        const body = JSON.parse(Buffer.concat(chunks));
        if (body.success) {
          return resolve(body.result);
        }
        reject(body.errors);
      });

      res.on('error', reject);
    });

    if (body) {
      req.write(JSON.stringify(body));
    }
    req.end();
  });
}