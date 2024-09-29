using System;
using System.Collections;
using Godot;

public partial class CloseRangeEnemyFSM : FSM
{
    public CloseRangeEnemyFSM()
    {
        AddState("Chase");
        AddState("Hurt");
        AddState("Dead");
    }

    public override void _Ready()
    {
        base._Ready();
        SetState(States["Chase"]);
    }

    public override void StateLogic(double delta)
    {
        if (State == States["Chase"])
        {
            parent.Call("Chase");
            parent.Call("Move");
        }
    }

    public override int GetTransition()
    {
        switch (State)
        {
            case 1:
                if (!AnimationPlayer.IsPlaying())
                {
                    return 0;
                }
                break;
        }
        return -1;
    }

    public override void EnterState(int _PreviousState, int _NewState)
    {
        switch (_NewState)
        {
            case 0:
                AnimationPlayer.Play("walk");
                break;
            case 1:
                AnimationPlayer.Play("hurt");
                break;
            case 2:
                AnimationPlayer.Play("dead");
                break;
        }
    }
}
