import "dotenv/config";
import express, { type Request, type Response } from "express";

const app = express();
const port = process.env.PORT || 3000;

app.get("/", (req: Request, res: Response) => {
  res
    .status(200)
    .json({ status: "ok", timestamp: new Date().toISOString(), port });
});

app.listen(port, () => {
  console.log(`Server is running on http://localhost:${port}`);
});
