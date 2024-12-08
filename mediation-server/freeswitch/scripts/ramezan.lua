-- ITNOA
-- --
-- -- Copyright (C) 1401|2022, Resa Co. All rights reserved.
--

local AYE_TIMES = {
0,
5,
10,
14,
17,
21,
25,
35,
40,
52,
64,
74,
88,
102,
111,
130,
146,
153,
159,
173,
184,
196,
202,
210,
229,
236,
242,
249,
258,
274,
282,
294,
303,
311,
324,
336,
343,
358,
366,
375,
382,
399,
407,
413,
420,
425,
434,
443,
467,
474,
483,
491,
499,
510,
519,
529,
535,
542,
548,
552,
558,
570,
576,
584,
590,
595,
610,
623,
634,
641,
651,
659,
673,
679,
685,
693,
699,
709,
718,
728,
738,
752,
757,
781
}

local function compute_score(score, inserted_date)
  if os.difftime(os.date("%d"), inserted_date) > 0 then
    return score + 1
  else
    return score
  end
end

local function find_seek_aye(play_soore_seek_offset)
  local last_aye_time = 0
  for i, v in ipairs(AYE_TIMES) do
    if v > play_soore_seek_offset then
      return last_aye_time
    end
    last_aye_time = v
  end
  if play_soore_seek_offset > 781 then
    return 0
  end
  return last_aye_time
end

local redis = require 'redis'
local redis_client = redis.connect('10.19.49.132', 6379)
local api = freeswitch.API()
local is_redis_connected = false
if (redis_client == nil) then
    api:execute("log", "Error: can't connect to redis")
end

if (redis_client:ping() == false) then
    api:execute("log", "Error: can't connect to redis")
else
    api:execute("log", "info ... connected to database")
    is_redis_connected = true
end

local canonical_caller_number = session:getVariable("caller_id_number")
if (canonical_caller_number:sub(1,1) == '0') then
    canonical_caller_number = canonical_caller_number
elseif (canonical_caller_number:sub(1,1) == '9') then
    canonical_caller_number = 0 .. canonical_caller_number
else
    canonical_caller_number = 0 .. canonical_caller_number:gsub("%s+", ""):gsub("[^0-9]", ""):sub(3)
end
api:execute("log", "info original caller number: " .. session:getVariable("caller_id_number"))
api:execute("log", "info canonical_caller_number: " .. canonical_caller_number)
local is_user_exist = false
local play_soore_seek_offset = 0
local userRedisKey = "user_" .. canonical_caller_number
local PLAY_SOORE_SEEK_OFFSET_FILED = "pssf"
local SCORE_FIELD = "s"
local USER_FIRST_SEEN_DAY_FIELD = "fsd"
local user_score = 1
local user_first_seen_day = os.date("%d")

if is_redis_connected then
    local res = redis_client:hmget(userRedisKey, PLAY_SOORE_SEEK_OFFSET_FILED, SCORE_FIELD, USER_FIRST_SEEN_DAY_FIELD)
    if res == nil or res[2] == nil then
      is_user_exist = false
    else
      is_user_exist = true
      if res[1] ~= nil then
        play_soore_seek_offset = res[1]
      end
      user_score = res[2]
      if res[3] ~= nil then
        user_first_seen_day = res[3]
      else
        user_first_seen_day = os.date("%d") - 1
      end
      api:execute("log", "info user is found and seek time is: " .. play_soore_seek_offset)
      api:execute("log", "info user is found and user score is: " .. user_score)
    end
end

session:sleep(150);
session:setVariable("read_terminator_used", "-");
local initWelcomeMessageTime = os.time();

local digits = nil
if is_user_exist then
  digits = 2
  digits = session:playAndGetDigits(1, 1, 1, 6500, "#", "/extra-voices/Rasool-tel-registered.wav", "phrase:error", "\\d+", "digits", 1000);
else
  digits = session:playAndGetDigits(1, 1, 1, 6500, "#", "/extra-voices/Rasool-tel.wav", "phrase:error", "\\d+", "digits", 1000);
end

local is_aye_played = false;
local is_soore_played = false;

if (session:getState() ~= 'CS_HANGUP') then
  if (session:getVariable("digits") == nil) then
    if is_user_exist then
      session:setVariable("digits", 2)
      digits = 2
    else
      session:setVariable("digits", 1)
      digits = 1
    end
  end

  api:execute("log", "info: digits: " .. digits);
  api:execute("log", "info: read_terminator_used: " .. session:getVariable("read_terminator_used"));

  if (session:getVariable("digits") == "1") then
    session:sleep(150);
    local day = (os.date("%d") - 2) % 30
    if (os.date("%d") - 2 <= 0) then
      day = 1
    end
    session:execute("playback", "/extra-voices/ITNOA.wav");
    session:sleep(150);
    session:execute("playback", "/extra-voices/sore_yasin_" .. day .. ".wav");
    is_aye_played = true;
    if is_redis_connected then
      redis_client:hset("user_" .. canonical_caller_number, PLAY_SOORE_SEEK_OFFSET_FILED, play_soore_seek_offset, SCORE_FIELD, compute_score(user_score, user_first_seen_day), USER_FIRST_SEEN_DAY_FIELD, os.date("%d"));
    end
  elseif (session:getVariable("digits") == "2") then
    session:sleep(150)
    local SAMPLE_RATE = 8000;
    if tonumber(play_soore_seek_offset) >= 8000 then
      play_soore_seek_offset = play_soore_seek_offset / 8000
    end
    api:execute("log", "info: play_soore_seek_offset before playback: " .. play_soore_seek_offset .. " tonumber: " .. tonumber(play_soore_seek_offset) .. " find_seek_aye: " .. find_seek_aye(tonumber(play_soore_seek_offset)))
    if find_seek_aye(tonumber(play_soore_seek_offset)) >= 5 then
      session:execute("playback", "/extra-voices/ITNOA.wav");
      session:sleep(150);
    end
    local init_soore_play_time = os.time()
    session:execute("playback", "/extra-voices/m036-saeed.wav" .. "@@" .. find_seek_aye(tonumber(play_soore_seek_offset)) * SAMPLE_RATE)
    is_soore_played = true
    local soore_play_time = os.difftime(os.time(), init_soore_play_time)
    if (is_redis_connected) then
      redis_client:hset("user_" .. canonical_caller_number, PLAY_SOORE_SEEK_OFFSET_FILED, soore_play_time + find_seek_aye(tonumber(play_soore_seek_offset)), SCORE_FIELD, compute_score(user_score, user_first_seen_day), USER_FIRST_SEEN_DAY_FIELD, os.date("%d"));
    end
  end
end

session:hangup();

local callDuration = os.difftime(os.time(), initWelcomeMessageTime)
if ((callDuration > 22) or is_aye_played or is_soore_played) then
  local response = nil
  if is_redis_connected then
    response = api:execute("curl", "http://0.0.0.0:80/sendsms?phoneNumber=" .. session:getVariable("caller_id_number") .. "&" .. "userScore=" .. compute_score(user_score, user_first_seen_day) .. "&" .. "callDuration=" .. callDuration .. " post");
  else
    response = api:execute("curl", "http://0.0.0.0:80/sendsms?phoneNumber=" .. session:getVariable("caller_id_number") .. "&" .. "callDuration=" .. callDuration .. " post");
  end
  api:execute("log", "info: caller_id_number: " .. session:getVariable("caller_id_number"));
  if (response ~= nil) then
    api:execute("log", "info: response is null!");
  else
    api:execute("log", "info: response: " .. response);
  end
end
