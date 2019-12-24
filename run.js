const { randomBytes } = require("crypto");
const { Elm } = require("./elm-main");

const App = Elm.Main.init({});

const run = async (functionId, input) => {
  const output = App.ports.output;
  const start = App.ports.start;

  const runId = randomBytes(16).toString("hex");
  const p = new Promise((resolve, reject) => {
    let timeout;
    const go = v => {
      if (v && v.runId === runId) {
        clearTimeout(timeout);
        output.unsubscribe(go);
        if (v.status === "ok") {
          console.log(
            [
              `resolved runId: ${runId}`,
              `    with input: ${input}`,
              `    to output:  ${v.output}`,
              ""
            ].join("\n")
          );
          resolve(v.output);
        } else if (v.status === "error") {
          console.log(
            [
              `rejected runId: ${runId}`,
              `    with input: ${input}`,
              `    to msg:     ${v.msg}`,
              ""
            ].join("\n")
          );
          reject(v.msg);
        } else {
          reject("error: invalid response status");
        }
      }
    };

    output.subscribe(go);

    timeout = setTimeout(() => {
      output.unsubscribe(go);
      reject("error: invalid input or time limit exceeded");
    }, 30 * 1000);
  });

  setTimeout(() => {
    start.send({ runId, functionId, input });
  }, Math.random() * 1000);

  return p;
};

(async () => {
  const f1s = new Array(10)
    .fill(null)
    .map((_, idx) => run("f1", new Array(idx).fill(1)));

  const f2s = new Array(14)
    .fill(null)
    .map((_, idx) => run("f2", "emosewa si mle".slice(idx)));

  try {
    console.log(await Promise.all([...f1s, ...f2s]));
  } catch (e) {
    console.error(e);
  }
})();
