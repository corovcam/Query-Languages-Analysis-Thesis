import fs from "fs";
import pino, { BaseLogger } from "pino";
import { Faker, SimpleFaker, en, faker } from "@faker-js/faker";

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

export function isNumber(n: any) {
  return !isNaN(parseFloat(n)) && isFinite(n);
}

export class CustomLogger {
  private static logFilePath: string;
  private static logFileStream: fs.WriteStream;
  private static logger: BaseLogger | Console;
  public static batchSizeToLog: number;

  public static initialize(startDateTime: Date, entityCount: number, percentageToLog = 5) {
    CustomLogger.batchSizeToLog = Math.ceil(entityCount * (percentageToLog / 100));
    CustomLogger.logFilePath = `logs/${startDateTime
      .toISOString()
      .replace(/:/g, "-")}.log`;
    fs.mkdirSync("logs", { recursive: true });
    CustomLogger.logFileStream = fs.createWriteStream(CustomLogger.logFilePath);
    CustomLogger.logger = console;
  }

  public static info(...data: any) {
    const timestamp = `[${new Date().toISOString()}] `;
    this.logFileStream.write(timestamp + "\t" + data.toString() + "\n");
    this.logger.info(timestamp, ...data);
  }

  public static error(...data: any) {
    const timestamp = `[${new Date().toISOString()}] `;
    this.logFileStream.write(timestamp + "\t" + data.toString() + "\n");
    this.logger.error(timestamp, ...data);
  }
}

export class CustomFaker {
  public static faker = faker;

  public static initialize() {
    // Using same seed and ref date for all faker functions to ensure consistency and reproducibility
    CustomFaker.faker.seed(123);
    CustomFaker.faker.setDefaultRefDate("2000-01-01T00:00:00.000Z");
  }
}

export function capitalizeFirstLetter(string: string) {
    return string.charAt(0).toUpperCase() + string.slice(1);
}