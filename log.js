const DEBUG = true;

const log = ({ jobId, status, input, msg, output }) => {
  if (DEBUG) {
    if (status === "ok") {
      console.log(
        [
          "",
          `ok =========================================`,
          `jobId:  ${jobId}`,
          `input:  ${JSON.stringify(input)}`,
          `output: ${output}`
        ].join("\n")
      );
    } else if (status === "error") {
      console.log(
        [
          "",
          `error ======================================`,
          `jobId: ${jobId}`,
          `input: ${JSON.stringify(input)}`,
          `msg:   ${msg}`
        ].join("\n")
      );
    }
  }
};

module.exports = {
  log
};
