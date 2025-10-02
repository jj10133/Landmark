
const { IPC } = BareKit
const Hyperswarm = require('hyperswarm');
const Hypercore = require('hypercore');
const b4a = require('b4a');
const Corestore = require('corestore');
const Hyperdrive = require('hyperdrive');

IPC.setEncoding('utf8');

// create a Corestore instance
const store = new Corestore("/tmp/landmark");
const swarm = new Hyperswarm();

const key = b4a.from("df1d78bdcf168e7a8cf48ddc7d945bff2beafa11ff34a7e7001e652315a30646", "hex");
let drive;

IPC.on("data", async (chunk) => {
    const rs = drive.createReadStream('/index.html');
    
    rs.on('data', (chunk) => {
      console.log('rs', chunk);
      IPC.write(chunk);
    });
    
    rs.on('error', (err) => {
      console.error('Stream error:', err);
    });
    
    rs.on('end', () => {
        // ⚠️ WARNING: This assumes that "END_OF_RESOURCE" is not part of the file content.
        const eofMarker = b4a.from("END_OF_RESOURCE");
        IPC.write(eofMarker);
        console.log("Sent EOF Marker.");
        // IPC is still open
    });
    
});

async function serveFile() {
  drive = new Hyperdrive(store, key);
  await drive.ready();

    swarm.on("connection", (conn) => {
        console.log("reaching out in p2p")
        store.replicate(conn)
    });
  swarm.join(drive.discoveryKey);
  await swarm.flush();

  for await (const file of drive.list('/')) {
    console.log('list', file);
  }
}

serveFile()
