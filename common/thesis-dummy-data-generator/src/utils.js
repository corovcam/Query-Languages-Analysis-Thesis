const pino = require('pino');

const logger = pino({
    level: process.env.PINO_LOG_LEVEL || 'debug',
    timestamp: pino.stdTimeFunctions.isoTime,
    transport: {
        targets: [
            {
                target: 'pino/file',
                options: { destination: Date.now() + ".log", mkdir: true }
            },
            {
                target: 'pino-pretty',
                options: {
                    colorize: true
                }
            }
        ]
    }
});

// console.infoCopy = console.info.bind(console);
// console.info = function(data) {
//     var timestamp = '[' + new Date().toUTCString() + '] ';
//     this.infoCopy(timestamp, data);
// };
// export const logger = console;

module.exports = { logger }