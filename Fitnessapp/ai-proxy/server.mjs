import http from "node:http";
import { randomUUID } from "node:crypto";
import { existsSync, readFileSync } from "node:fs";
import { resolve } from "node:path";

loadEnvironmentFile();

const port = Number(process.env.PORT || 8787);
const apiKey = process.env.DEEPSEEK_API_KEY;
const deepSeekURL = "https://api.deepseek.com/chat/completions";
const chatModel = resolveModelName(process.env.DEEPSEEK_CHAT_MODEL || "deepseek-chat");
const recommendationModel = resolveModelName(process.env.DEEPSEEK_RECOMMENDATION_MODEL || "deepseek-v4-pro");
const deepSeekTimeoutMilliseconds = Number(process.env.DEEPSEEK_TIMEOUT_MS || 25000);
const recommendationTimeoutMilliseconds = Number(process.env.RECOMMENDATION_TIMEOUT_MS || 18000);

function resolveModelName(modelName) {
  switch (String(modelName || "").trim().toLowerCase()) {
    case "flash":
      return process.env.DEEPSEEK_FLASH_MODEL || "deepseek-chat";
    case "pro":
      return process.env.DEEPSEEK_PRO_MODEL || "deepseek-v4-pro";
    default:
      return modelName;
  }
}

function loadEnvironmentFile() {
  const envPath = resolve(process.cwd(), ".env");
  if (!existsSync(envPath)) {
    return;
  }

  const lines = readFileSync(envPath, "utf8").split(/\r?\n/);
  for (const line of lines) {
    const trimmed = line.trim();
    if (!trimmed || trimmed.startsWith("#")) {
      continue;
    }

    const separatorIndex = trimmed.indexOf("=");
    if (separatorIndex === -1) {
      continue;
    }

    const key = trimmed.slice(0, separatorIndex).trim();
    const value = trimmed.slice(separatorIndex + 1).trim().replace(/^["']|["']$/g, "");
    if (key && process.env[key] === undefined) {
      process.env[key] = value;
    }
  }
}

function sendJSON(response, statusCode, payload) {
  response.writeHead(statusCode, { "Content-Type": "application/json" });
  response.end(JSON.stringify(payload));
}

async function readJSON(request) {
  const chunks = [];
  for await (const chunk of request) {
    chunks.push(chunk);
  }

  if (chunks.length === 0) {
    return {};
  }

  return JSON.parse(Buffer.concat(chunks).toString("utf8"));
}

async function deepSeekChat(messages, options = {}) {
  if (!apiKey) {
    throw new Error("DEEPSEEK_API_KEY is not set");
  }

  const body = {
    model: options.model,
    messages,
    reasoning_effort: options.reasoningEffort || "medium",
    stream: false
  };

  if (options.thinkingEnabled === true) {
    body.thinking = { type: "enabled" };
  }

  if (options.responseFormat) {
    body.response_format = options.responseFormat;
  }

  const controller = new AbortController();
  const timeout = setTimeout(() => controller.abort(), deepSeekTimeoutMilliseconds);

  const response = await fetch(deepSeekURL, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      Authorization: `Bearer ${apiKey}`
    },
    body: JSON.stringify(body),
    signal: controller.signal
  });
  clearTimeout(timeout);

  if (!response.ok) {
    const detail = await response.text();
    throw new Error(`DeepSeek request failed: ${response.status} ${detail}`);
  }

  const payload = await response.json();
  return payload?.choices?.[0]?.message?.content ?? "";
}

function exerciseCatalogText(exercises) {
  return exercises
    .map((exercise) => {
      return [
        `id: ${exercise.id}`,
        `name: ${exercise.name}`,
        `category: ${exercise.category}`,
        `intensity: ${exercise.intensity}`,
        `kcalPerMinute: ${exercise.kcalPerMinute}`,
        `level: ${exercise.level}`,
        `instructions: ${exercise.instructions}`
      ].join("\n");
    })
    .join("\n\n");
}

function recommendationSystemPrompt() {
  return [
    "You are a fitness coach API for an iOS fitness app.",
    "Return strict JSON only.",
    "Use only exercises from the provided catalog.",
    "Return 2 to 4 items only.",
    "Do not include medical claims.",
    "Keep the plan realistic for the user's profile, calorie target, and available minutes.",
    "The JSON schema is:",
    "{",
    '  "summary": "string",',
    '  "items": [',
    '    {',
    '      "exerciseId": "string",',
    '      "name": "string",',
    '      "durationMinutes": 1,',
    '      "estimatedCalories": 1,',
    '      "intensity": "low|medium|high",',
    '      "instructions": "string"',
    "    }",
    "  ]",
    "}"
  ].join("\n");
}

function buildRecommendation(payload, aiJSON) {
  const profile = payload.profile;
  const exerciseMap = new Map((payload.exercises || []).map((exercise) => [exercise.id, exercise]));
  const items = (Array.isArray(aiJSON.items) ? aiJSON.items : [])
    .slice(0, 4)
    .map((item) => {
      const catalogExercise = exerciseMap.get(String(item.exerciseId || ""));
      const durationMinutes = Math.max(1, Number(item.durationMinutes || 1));
      const estimatedCalories = catalogExercise
        ? durationMinutes * Number(catalogExercise.kcalPerMinute || 0)
        : Number(item.estimatedCalories || 0);

      return {
        exerciseId: String(item.exerciseId || catalogExercise?.id || ""),
        name: String(catalogExercise?.name || item.name || ""),
        durationMinutes,
        estimatedCalories,
        intensity: String(catalogExercise?.intensity || item.intensity || "medium"),
        instructions: String(catalogExercise?.instructions || item.instructions || "")
      };
    })
    .filter((item) => item.exerciseId && item.name);

  const totalEstimatedCalories = items.reduce((total, item) => {
    return total + Number(item.estimatedCalories || 0);
  }, 0);

  return {
    id: randomUUID(),
    userId: profile.userId,
    source: "ai",
    summary: String(aiJSON.summary || "AI workout recommendation generated."),
    dailyCalorieTarget: Number(profile.dailyCalorieTarget || 0),
    dailyWorkoutDurationMinutes: Number(profile.dailyWorkoutDurationMinutes || 0),
    totalEstimatedCalories,
    items,
    createdAt: isoDate()
  };
}

function buildFallbackRecommendation(payload, reason) {
  const profile = payload.profile || {};
  const exercises = Array.isArray(payload.exercises) ? payload.exercises : [];
  const filtered = exercises
    .filter((exercise) => exercise.isActive !== false)
    .filter((exercise) => {
      if (profile.fitnessLevel === "beginner") {
        return exercise.level === "beginner" && exercise.intensity !== "high";
      }

      if (profile.fitnessLevel === "intermediate") {
        return exercise.level === "beginner" || exercise.level === "intermediate";
      }

      return true;
    })
    .sort((lhs, rhs) => Number(rhs.kcalPerMinute || 0) - Number(lhs.kcalPerMinute || 0));

  const selected = balancedSelection(filtered).slice(0, 4);
  const durations = allocateDurations(Number(profile.dailyWorkoutDurationMinutes || 0), selected.length);
  const items = selected.map((exercise, index) => ({
    exerciseId: exercise.id,
    name: exercise.name,
    durationMinutes: durations[index],
    estimatedCalories: durations[index] * Number(exercise.kcalPerMinute || 0),
    intensity: exercise.intensity,
    instructions: exercise.instructions
  }));
  const totalEstimatedCalories = items.reduce((total, item) => total + item.estimatedCalories, 0);

  return {
    id: randomUUID(),
    userId: String(profile.userId || ""),
    source: "ruleBased",
    summary: `Generated a fast backup plan because AI recommendation was unavailable: ${reason}`,
    dailyCalorieTarget: Number(profile.dailyCalorieTarget || 0),
    dailyWorkoutDurationMinutes: Number(profile.dailyWorkoutDurationMinutes || 0),
    totalEstimatedCalories,
    items,
    createdAt: isoDate()
  };
}

function balancedSelection(exercises) {
  const categories = ["cardio", "strength", "core", "fullBody", "mobility", "recovery"];
  const selected = [];

  for (const category of categories) {
    const exercise = exercises.find((item) => item.category === category && !selected.includes(item));
    if (exercise) {
      selected.push(exercise);
    }
  }

  for (const exercise of exercises) {
    if (!selected.includes(exercise)) {
      selected.push(exercise);
    }
  }

  return selected;
}

function allocateDurations(totalMinutes, itemCount) {
  if (itemCount <= 0) {
    return [];
  }

  const minutes = Math.max(totalMinutes, itemCount);
  const baseDuration = Math.floor(minutes / itemCount);
  const remainder = minutes % itemCount;

  return Array.from({ length: itemCount }, (_, index) => baseDuration + (index < remainder ? 1 : 0));
}

async function handleRecommendation(request, response) {
  const payload = await readJSON(request);
  const profile = payload.profile;
  const exercises = Array.isArray(payload.exercises) ? payload.exercises : [];

  try {
    const content = await withTimeout(
      deepSeekChat(
        [
          { role: "system", content: recommendationSystemPrompt() },
          {
            role: "user",
          content: [
            `User profile: ${JSON.stringify(profile)}`,
            `Plan preference: ${String(payload.planPreference || "No extra preference.")}`,
            "Exercise catalog:",
            exerciseCatalogText(exercises)
          ].join("\n\n")
          }
        ],
        {
          model: recommendationModel,
          responseFormat: { type: "json_object" },
          reasoningEffort: "low",
          thinkingEnabled: false
        }
      ),
      recommendationTimeoutMilliseconds,
      "AI recommendation timed out"
    );

    const parsed = JSON.parse(content);
    sendJSON(response, 200, buildRecommendation(payload, parsed));
  } catch (error) {
    sendJSON(response, 200, buildFallbackRecommendation(payload, error.name === "AbortError" ? "request timed out" : error.message));
  }
}

function withTimeout(promise, timeoutMilliseconds, message) {
  return Promise.race([
    promise,
    new Promise((_, reject) => {
      setTimeout(() => reject(new Error(message)), timeoutMilliseconds);
    })
  ]);
}

async function handleChat(request, response) {
  const payload = await readJSON(request);
  const content = await deepSeekChat(
    [
      {
        role: "system",
        content: "You are a concise fitness assistant. Give practical workout guidance and avoid medical diagnosis."
      },
      { role: "user", content: String(payload.message || "") }
    ],
    {
      model: chatModel,
      reasoningEffort: "medium",
      thinkingEnabled: false
    }
  );

  sendJSON(response, 200, {
    id: randomUUID(),
    userId: String(payload.userId || ""),
    role: "assistant",
    content,
    createdAt: isoDate()
  });
}

function isoDate() {
  return new Date().toISOString().replace(/\.\d{3}Z$/, "Z");
}

const server = http.createServer(async (request, response) => {
  try {
    if (request.method === "GET" && request.url === "/health") {
      sendJSON(response, 200, { ok: true });
      return;
    }

    if (request.method === "POST" && request.url === "/chat") {
      await handleChat(request, response);
      return;
    }

    if (request.method === "POST" && request.url === "/recommendation") {
      await handleRecommendation(request, response);
      return;
    }

    sendJSON(response, 404, { error: "Not found" });
  } catch (error) {
    sendJSON(response, 500, { error: error.message || "Unknown error" });
  }
});

server.listen(port, () => {
  console.log(`AI proxy listening on http://10.24.203.75:${port}`);
  console.log(`Chat model: ${chatModel}`);
  console.log(`Recommendation model: ${recommendationModel}`);
});
