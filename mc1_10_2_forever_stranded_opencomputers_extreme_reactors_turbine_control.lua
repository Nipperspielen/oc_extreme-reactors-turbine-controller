-- ============================================
-- OpenComputers Extreme Reactors Turbine Control Setup Guide
-- Minecraft 1.10.2 / Forever Stranded 2.0.9
-- Version: 1.0.0
-- Author: Bruce Mitchell
-- Date: 2026-03-12

-- Tested with:
--   Minecraft: 1.10.2
--   Modpack: Forever Stranded 2.0.9
--   Extreme Reactors: 1.10.2-0.4.5.49
--   OpenComputers: MC1.10.2-1.7.5.245
-- 
-- Requirements:
--   Extreme Reactors installed
--   OpenComputers installed (not included in Forever Stranded 2.0.9)
--   Reactor and turbine already built
--   Reactor must be connected to turbine with fluid ports and pipes
--   Modpack has no built-in way to automate turbines (no redstone control, no computer mod included)
--   ComputerCraft does not work with Extreme Reactors in this modpack
--
-- NOTE:
-- Forever Stranded has several OpenComputers quirks
-- This setup required hours of trial and error
-- Steps below avoid common mistakes
--
-- Tested setup:
-- Reactor: 5x5x5, 5 control rods, gold coolant
-- Turbine: 5x5x10, 2 full electrum coils
-- Fluid pipes: EnderIO - Ender Fluid Conduit required for full steam flow
-- ============================================

-- Required Parts
-- Computer Case Tier 1
-- Screen Tier 1
-- Keyboard
-- Adapter
-- Disk Drive
-- 2x Cable
-- EEPROM (Lua BIOS)
-- Floppy Disk (OpenOS)
-- CPU Tier 1
-- Hard Disk Drive Tier 1
-- 2x Memory Tier 1
-- Graphics Card Tier 1

-- Extreme Reactors
-- Turbine Computer Port (Legacy)

------------------------------------------------
-- STEP 1 – Build the Computer
------------------------------------------------
-- Place Computer Case
-- Install inside the case:
--   CPU
--   Memory x2
--   Hard Disk Drive
--   Graphics Card
--   EEPROM
-- Close case

-- Attach:
-- Screen
-- Keyboard (stick on side of screen)
-- Disk Drive
-- Adapter
-- Connect boxes with cables (one cable can connect multiple)

------------------------------------------------
-- STEP 2 – Power Requirements
------------------------------------------------
-- OpenComputers Computer Case requires RF power
-- In this pack other mod power cables did not power the case directly
-- Power blocks worked when placed next to the case
-- Place EnderIO capacitor next to the case for steady power
-- Connect capacitor to your power network
-- This provides steady power without needing a generator
-- If computer has no power it will not boot

------------------------------------------------
-- STEP 3 – Connect to Turbine
------------------------------------------------
-- Replace one turbine glass block with a Turbine Computer Port (Legacy)
-- (Extreme Reactors block, not OpenComputers)
--
-- Place Adapter touching Turbine Computer Port
-- Cable from Adapter to Computer Case

------------------------------------------------
-- STEP 4 – Install OpenOS (Old method for 1.10.2)
------------------------------------------------
-- Insert OpenOS Floppy into Disk Drive

-- 1. Turn computer on (button inside computer case)

-- 2. Click on computer screen
--   If typing "install" in the popup window does NOT work, do this:

-- 3. At # prompt type:
--   ls

-- 4. Find floppy mount name (usually /mnt/xxxx)
--   cd /mnt/xxxx
--   ls

-- 5. Copy OS to hard drive:
--   cp -r * /home

-- 6. Remove floppy disk

-- 7. Reboot:
--   reboot  (if doesn't work, push button inside case)

------------------------------------------------
-- STEP 5 – Verify OS Installed
------------------------------------------------
-- After reboot you should see:
--   OpenOS #
-- Type:
--   ls
-- If you see directories: bin, boot, home, lib, etc, tmp, OS is working
-- If you are not in the /home directory
-- Type:
--   cd /home

------------------------------------------------
-- STEP 6 – Copy Turbine Program
------------------------------------------------
-- Create empty file on OpenComputers computer in /home:
--   touch turbine.lua

-- Exit the world (OpenComputers will not see file changes while world is loaded)

-- Open save folder (example):
-- C:\Users\USER\curseforge\minecraft\Instances\Forever Stranded\saves\WORLDSAVE\opencomputers\LONG-HEX-NUMBER\home

-- Find turbine.lua in the computer folder
-- Edit with Notepad
-- Copy turbine.lua from web
-- Paste into this file
-- Save file

-- Load the Minecraft world again

------------------------------------------------
-- STEP 7 – Run Program
------------------------------------------------
-- Run manually:
--   lua turbine.lua

-- ============================================

local component = require("component")
local event = require("event")
local term = require("term")

if not component.isAvailable("br_turbine") then
  print("No br_turbine found")
  return
end

local turbine = component.br_turbine
local addr = turbine.address

local function call(name, ...)
  return component.invoke(addr, name, ...)
end

local FLOW = 2000
local COILS_ON_RPM = 1780
local COILS_OFF_RPM = 1700

call("setActive", true)
call("setFluidFlowRateMax", FLOW)
call("setInductorEngaged", false)

while true do
  local connected = call("getConnected")
  local assembled = call("getMultiblockAssembled")
  local active = call("getActive")
  local rpm = call("getRotorSpeed")
  local flow = call("getFluidFlowRate")
  local coils = call("getInductorEngaged")
  local rf = call("getEnergyProducedLastTick")

  if connected and assembled then
    if not active then
      call("setActive", true)
    end

    call("setFluidFlowRateMax", FLOW)

    if rpm >= COILS_ON_RPM and not coils then
      call("setInductorEngaged", true)
      coils = true
    elseif rpm <= COILS_OFF_RPM and coils then
      call("setInductorEngaged", false)
      coils = false
    end
  end

  term.clear()
  term.setCursor(1, 1)
  print("Extreme Reactors Turbine Controller")
  print("-----------------------------------")
  print("Connected:  " .. tostring(connected))
  print("Assembled:  " .. tostring(assembled))
  print("Active:     " .. tostring(active))
  print("Coils:      " .. tostring(coils))
  print("RPM:        " .. string.format("%.1f", rpm))
  print("Flow:       " .. string.format("%.1f", flow))
  print("RF/t:       " .. string.format("%.1f", rf))
  print("")
  print("Coils ON at:  " .. COILS_ON_RPM)
  print("Coils OFF at: " .. COILS_OFF_RPM)

  event.pull(1)
end
