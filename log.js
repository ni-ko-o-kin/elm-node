const DEBUG = true;

const log = ({ status, input, msg, output }) => {
  if (DEBUG) {
    if (status === "ok") {
      console.log(
        [
          "",
          `ok =========================================`,
          `input:  ${JSON.stringify(input)}`,
          `output: ${output}`,
        ].join("\n")
      );
    } else if (status === "error") {
      console.log(
        [
          "",
          `error ======================================`,
          `input: ${JSON.stringify(input)}`,
          `msg:   ${msg}`,
        ].join("\n")
      );
    }
  }
};

module.exports = {
  log,
};
