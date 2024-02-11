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

const parseRequest = (chunk) => {
  const decoder = new TextDecoder();
  const message = decoder.decode(chunk);
  const lengthMatch = message.match(/Content-Length: (\d+)\r\n/);
  const contentLength = parseInt(lengthMatch[1], 10);
  const messageStart = message.indexOf("\r\n\r\n") + 4;
  const body = message.slice(messageStart, messageStart + contentLength);
  return JSON.parse(body);
};

const documents = {};

for await (const chunk of Deno.stdin.readable) {
  log(new TextDecoder().decode(chunk));
  const request = parseRequest(chunk);
  const { method, id } = request;

  if (method === "initialize") {
    const result = {
      capabilities: {
        textDocumentSync: 1,
        documentFormattingProvider: true,
      },
      serverInfo: {
        name: "lsp-from-scratch",
        version: "1.0",
      },
    };
    respond({ id, result });
  }
  if (method === "textDocument/didOpen") {
    const { uri, text } = request.params.textDocument;
    documents[uri] = text;
  }
  if (method === "textDocument/didChange") {
    const { uri } = request.params.textDocument;
    const changes = request.params.contentChanges;
    documents[uri] = changes[0].text;
  }
  if (method === "textDocument/formatting") {
    const { uri } = request.params.textDocument;
    const edits = [];
    const text = documents[uri];
    text.split("\n").forEach((line, lineIndex) => {
      if (line.indexOf("mov") !== -1) {
        edits.push({
          range: {
            start: { line: lineIndex, character: line.indexOf("mov") },
            end: { line: lineIndex, character: line.indexOf("mov") + 3 },
          },
          newText: "MOV",
        });
      }
    });

    respond({
      id,
      result: edits,
    });
  }
  if (method === "shutdown") {
    respond({ id, result: null });
  }
  if (method === "exit") {
    Deno.exit(0);
  }
}
