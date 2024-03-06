import fs from 'fs';
import pino, { BaseLogger } from 'pino';

// export const createLogger = (startDateTime: Date) => pino({
//     level: process.env.PINO_LOG_LEVEL || 'debug',
//     timestamp: pino.stdTimeFunctions.isoTime,
//     transport: {
//         targets: [
//             {
//                 target: 'pino/file',
//                 options: { destination: `logs/${startDateTime.toISOString().replace(/:/g, "-")}.log`, mkdir: true }
//             },
//             {
//                 target: 'pino-pretty',
//                 options: {
//                     colorize: true
//                 }
//             }
//         ]
//     }
// });

export const createLogger = (startDateTime: Date) => {
    const logFilePath = `logs/${startDateTime.toISOString().replace(/:/g, "-")}.log`;
    fs.mkdirSync('logs', { recursive: true });
    fs.writeFileSync(logFilePath, '');
    // @ts-ignore
    console.infoCopy = console.info.bind(console);
    console.info = function(data) {
        var timestamp = '[' + new Date().toISOString() + '] ';
        fs.appendFileSync(logFilePath, timestamp + "\t" + data + '\n')
        this.infoCopy(timestamp, data);
    };
    return console;
}
