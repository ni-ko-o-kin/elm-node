const { randomBytes } = require("crypto");
const { Elm } = require("./elm-main");
const { log } = require("./log");

const App = Elm.Main.init({});

const run = async (functionId, input) => {
  const output = App.ports.output;
  const start = App.ports.start;

  const jobId = randomBytes(16).toString("hex");
  const p = new Promise(resolve => {
    try {
      let timeout;
      const go = v => {
        if (v.jobId === jobId) {
          clearTimeout(timeout);
          output.unsubscribe(go);
          log({ ...v, input });

          if (v.status === "ok") {
            resolve({ ok: v.output });
          } else if (v.status === "error") {
            resolve({ error: v.msg });
          } else {
            resolve({ error: "invalid response status" });
          }
        }
      };

      output.subscribe(go);

      timeout = setTimeout(() => {
        output.unsubscribe(go);
        resolve({ error: "invalid jobId or time limit exceeded" });
      }, 20 * 1000);
    } catch (e) {
      resolve({ error: "unexpected error" });
    }
  });

  setTimeout(() => {
    start.send({ jobId, functionId, input });
  }, Math.random() * 1000);

  return p;
};

(async () => {
  try {
    const okF1 = await run("f1", [1, 1, 1, 1]);
    console.log("--> okF1", okF1);

    const okF2 = await run("f2", "emosewa si mle");
    console.log("--> okF2", okF2);

    const errorF2 = await run("f2", "");
    console.log("--> errorF2", errorF2);

    const errorF1 = await run("f1", []);
    console.log("--> errorF1", errorF1);

    const invalidInput = await run("f2", 123456);
    console.log("--> invalid input", invalidInput);
  } catch (e) {
    console.error("--> throw", e);
  }
})();
