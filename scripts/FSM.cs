using Godot;
using Godot.Collections;

public partial class FSM : Node
{
    public Dictionary<string, int> States = new Dictionary<string, int> { };
    public int PreviousState = -1;
    public int State = -1;
    public Character parent;
    public AnimationPlayer AnimationPlayer;

    public override void _Ready()
    {
        parent = GetParent<Character>();
        GD.Print(parent);
        AnimationPlayer = parent.GetNode<AnimationPlayer>("AnimationPlayer");
    }

    public override void _PhysicsProcess(double delta)
    {
        if (State != -1)
        {
            StateLogic(delta);
            int transition = GetTransition();
            if (transition != -1)
            {
                SetState(transition);
            }
        }
    }

    public virtual void StateLogic(double delta) { }

    public virtual int GetTransition()
    {
        return -1;
    }

    public void AddState(string new_state)
    {
        States[new_state] = States.Count;
    }

    public void SetState(int NewState)
    {
        ExitState(State);
        PreviousState = State;
        State = NewState;
        EnterState(PreviousState, State);
    }

    public virtual void EnterState(int _PreviousState, int _NewState) { }

    public virtual void ExitState(int _StateExited) { }
}
