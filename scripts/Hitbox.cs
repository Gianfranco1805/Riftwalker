using Godot;

[GlobalClass]
public partial class Hitbox : Area2D
{
    [Export]
    public int damage = 1;

    Vector2 KnockBackDirection = Vector2.Zero;

    [Export]
    public int KnockBackForce = 1000;

    public bool BodyInside = false;
    public Timer _timer;

    public override void _Ready()
    {
        CollisionShape2D CollisionShape = GetChild<CollisionShape2D>(0);
        _timer = new Timer();
        System.Diagnostics.Debug.Assert(CollisionShape != null);
        _timer.WaitTime = 1;
        AddChild(_timer);
        GD.Print("this the one");
    }

    public Hitbox()
    {
        Connect("body_entered", new Callable(this, "OnBodyEntered"));
        // Connect("body_entered", new Callable(this, "_on_body_exited"));
    }

    public void OnBodyEntered(Node2D body)
    {
        // BodyInside = true;
        // _timer.Start();
        // while (BodyInside)
        // {
        //     collide(body);
        //     await ToSignal(_timer, "timeout");
        // }
        GD.Print(KnockBackDirection);

        body.Call("take_damage", damage, KnockBackDirection, KnockBackForce);
    }

    // public void _on_body_exited(Node2D body)
    // {
    //     body.(damage, KnockBackDirection, KnockBackForce);
    //     QueueFree();
    // }

    // public void collide(Node2D body)
    // {
    //     if (body == null || !body.HasMethod("take_damage"))
    //     {
    //         QueueFree();
    //     }
    //     else
    //     {
    //         body.Call("take_damage", damage, KnockBackDirection, KnockBackForce);
    //     }
    // }
}
