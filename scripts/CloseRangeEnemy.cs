using System;
using Godot;

public partial class CloseRangeEnemy : Enemy
{
    public Hitbox Hitbox;

    public override void _Ready()
    {
        base._Ready();
        Hitbox = GetNode<Hitbox>("Hitbox");
    }

    public override void _Process(double delta)
    {
        Hitbox.Set("KnockBackDirection", Velocity.Normalized());
    }
}
