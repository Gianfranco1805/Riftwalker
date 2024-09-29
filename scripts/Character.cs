using System.Security.Cryptography.X509Certificates;
using Godot;

public partial class Character : CharacterBody2D
{
	float FRICTION = 0.15f;

	[Export]
	int acceleration = 100;

	[Export]
	int max_speed = 200;

	public AnimatedSprite2D AnimatedSprite;

	public override void _Ready()
	{
		AnimatedSprite = GetNode<AnimatedSprite2D>("AnimatedSprite2D");
	}

	public Vector2 mov_direction = Vector2.Zero;

	public override void _PhysicsProcess(double delta)
	{
		MoveAndSlide();
		Velocity = Velocity.Lerp(Vector2.Zero, FRICTION);
	}

	public void Move()
	{
		mov_direction = mov_direction.Normalized();
		Velocity += mov_direction * acceleration;
		Velocity = Velocity.LimitLength(max_speed);
	}
}
