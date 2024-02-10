type integer = number;

interface Message {
  jsonrpc: string;
}

interface ResponseError {
  code: integer;
  message: string;
  data?: string | number | boolean | array | object | null;
}

interface ResponseMessage extends Message {
  id: number | string | null;
  result?: string | number | boolean | array | object | null;
  error?: ResponseError;
}

const logFile = "log.txt";
const file = await Deno.open(logFile, {
  create: true,
  write: true,
  truncate: true,
});
file.close();

const log = (data) => {
  Deno.writeTextFileSync(logFile, data + "\n", { append: true });
};

const respond = (message) => {
  const encoder = new TextEncoder();
  const payload = JSON.stringify(message);
  const length = encoder.encode(payload).length;
  const response = `Content-Length: ${length}\r\n\r\n${payload}`;
  Deno.stdout.write(encoder.encode(response));
};

const decoder = new TextDecoder();
for await (const chunk of Deno.stdin.readable) {
  const message = decoder.decode(chunk);
  log(message);

  const lengthMatch = message.match(/Content-Length: (\d+)\r\n/);
  const contentLength = parseInt(lengthMatch[1], 10);
  const messageStart = message.indexOf("\r\n\r\n") + 4;
  const body = message.slice(messageStart, messageStart + contentLength);
  const { method, id } = JSON.parse(body);

  if (method === "initialize") {
    const result = {
      capabilities: {
        documentFormattingProvider: true,
      },
      serverInfo: {
        name: "lsp-from-scratch",
        version: "1.0",
      },
    };
    respond({ id, result });
  }
  if (method === "shutdown") {
    respond({ id, result: null });
  }
  if (method === "exit") {
    Deno.exit(0);
  }
}
