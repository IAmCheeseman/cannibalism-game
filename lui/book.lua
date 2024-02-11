local kirigami = require("lib.kirigami")
local LUI = require("lib.LUI")

local Label = require("lui.label")
local ProgressBar = require("lui.progressbar")

local Book = LUI.Element()

function Book:init(sprite)
  self.sprite = sprite


  self.emotionBarEmpty = love.graphics.newImage("assets/emotionbarempty.png")
  self.emotionBarFull = love.graphics.newImage("assets/emotionbarfull.png")

  self.emotions = {
    ProgressBar(
        self, love.graphics.newImage("assets/happinessicon.png"),
        self.emotionBarEmpty, self.emotionBarFull),
    ProgressBar(
        self, love.graphics.newImage("assets/tranquilityicon.png"),
        self.emotionBarEmpty, self.emotionBarFull),
    ProgressBar(
        self, love.graphics.newImage("assets/angericon.png"),
        self.emotionBarEmpty, self.emotionBarFull),
    ProgressBar(
        self, love.graphics.newImage("assets/fearicon.png"),
        self.emotionBarEmpty, self.emotionBarFull),
    ProgressBar(
        self, love.graphics.newImage("assets/sanityicon.png"),
        self.emotionBarEmpty, self.emotionBarFull),
  }

  self.emotions[1].fullModulate = {1, 1, 0}
  self.emotions[2].fullModulate = {0, 1, 0}
  self.emotions[3].fullModulate = {1, 0, 0}
  self.emotions[4].fullModulate = {1, 0, 1}
  self.emotions[5].fullModulate = {0.5, 0.5, 0.5}

  self.traits = {
    "psychopathy",
    "sense of justice",
    "courageous",
  }

  for i, trait in ipairs(self.traits) do
    self.traits[i] = Label(self, trait)
  end

  for _, bar in ipairs(self.emotions) do
    bar.value = love.math.random()
  end

  self.leftTitle = Label(self, "emotions", font)
  self.rightTitle = Label(self, "traits", font)
end

function Book:onRender(region)
  local left, right = region:splitHorizontal(0.5, 0.5)
  left = left:pad(6)
  right = right:pad(6)
  local leftTitle, leftContent = left:splitVertical(0.15, 0.8)
  local rightTitle, rightContent = right:splitVertical(0.15, 0.8)
  local imageScale = region:getScaleToFit(self.sprite.image:getDimensions())

  love.graphics.setColor(1, 1, 1, 1)
  self.sprite:draw(region.x, region.y, 0, imageScale)

  for i, row in ipairs(leftContent:grid(1, 5)) do
    self.emotions[i]:render(row)
  end

  for i, row in ipairs(rightContent:grid(1, #self.traits)) do
    self.traits[i]:render(row)
  end

  love.graphics.setColor(34/255, 32/255, 52/255)

  self.leftTitle:render(leftTitle)
  self.rightTitle:render(rightTitle)
end

return Book
