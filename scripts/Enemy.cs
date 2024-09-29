using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Linq;
using Godot;

public partial class Enemy : Character
{
    public NavigationAgent2D Navigation;
    public CharacterBody2D Player;
    public Timer PathTimer;

    public override void _Ready()
    {
        base._Ready();
        Player = GetTree().CurrentScene.GetNode<CharacterBody2D>("Player");
        PathTimer = GetNode<Timer>("PathTimer");
        Navigation = GetNode<NavigationAgent2D>("NavigationAgent2D");
    }

    public void Chase()
    {
        if (!Navigation.IsTargetReached())
        {
            Vector2 VectorToNextPoint = Navigation.GetNextPathPosition() - GlobalPosition;

            mov_direction = VectorToNextPoint;

            if (VectorToNextPoint.X > 0 && AnimatedSprite.FlipH)
            {
                AnimatedSprite.FlipH = false;
            }
            else if (VectorToNextPoint.X < 0 && AnimatedSprite.FlipH != true)
            {
                AnimatedSprite.FlipH = true;
            }
        }
    }

    public void _on_path_timer_timeout()
    {
        if (IsInstanceValid(Player))
        {
            GetPathToPlayer();
        }
        else
        {
            PathTimer.Stop();
            mov_direction = Vector2.Zero;
        }
    }

    public void GetPathToPlayer()
    {
        if (IsInstanceValid(Player))
        {
            Navigation.TargetPosition = Player.Position;
        }
    }
}
