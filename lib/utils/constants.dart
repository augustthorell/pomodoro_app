import 'package:flutter/material.dart';
import 'package:pomodoro_app/model/status.dart';

const Map<PomodoroStatus, String> statusDescription = {
  PomodoroStatus.initPomodoro: 'START',
  PomodoroStatus.runningPomodoro: 'WORK TIME',
  PomodoroStatus.pausedPomodoro: 'PAUSED',
  PomodoroStatus.breakPomodoro: 'REST TIME',
  PomodoroStatus.pausedBreak: 'START BREAK',
};

const Map<PomodoroStatus, MaterialColor> statusColor = {
  PomodoroStatus.initPomodoro: Colors.customWhite,
  PomodoroStatus.runningPomodoro: Colors.customValue,
  PomodoroStatus.pausedPomodoro: Colors.yellow,
  PomodoroStatus.breakPomodoro: Colors.customWhite,
  PomodoroStatus.pausedBreak: Colors.yellow,
};

const Map<PomodoroStatus, IconData> statusIcon = {
  PomodoroStatus.initPomodoro: Icons.play_arrow,
  PomodoroStatus.runningPomodoro: Icons.pause,
  PomodoroStatus.pausedPomodoro: Icons.play_arrow,
  PomodoroStatus.breakPomodoro: Icons.pause,
  PomodoroStatus.pausedBreak: Icons.play_arrow,
};
