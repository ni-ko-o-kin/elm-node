const { randomBytes } = require("crypto");
const { Elm } = require("./elm-main");
const { log } = require("./log");

const App = Elm.Main.init({});
const output = App.ports.output;
const start = App.ports.start;

const run = async (functionId, input) =>
  new Promise((resolve) => {
    start.send({
      functionId,
      input,
      resolve,
    });
  });

output.subscribe(({ status, msg, output, input: { resolve } }) => {
  if (status === "ok") {
    resolve({ ok: output });
  } else if (status === "error") {
    resolve({ error: msg });
  } else {
    resolve({ error: "invalid response status" });
  }
});

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
