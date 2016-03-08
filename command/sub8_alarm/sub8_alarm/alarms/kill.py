import rospy
from kill_handling.msg import Kill
from kill_handling.broadcaster import KillBroadcaster
from kill_handling.srv import SetKill
from std_msgs.msg import Header


class HandleKill(object):
    '''Interface to legacy kill system (which we're not getting rid of for now)'''
    alarm_name = 'kill'

    def __init__(self):
        # Keep some knowledge of which thrusters we have working
        self.dropped_thrusters = []
        self.kill_br = KillBroadcaster(id='alarm-kill', description='Alarm Kill')
        self.set_kill = rospy.ServiceProxy('/set_kill', SetKill)

    def handle(self, time_sent, parameters):
        if parameters['kill']:
            self.kill_br.send(True)
        else:
            kill_ids = [
                'alarm-kill',
                'initial'
            ]
            for kill_id in kill_ids:
                self.set_kill(
                    Kill(
                        header=Header(stamp=rospy.Time.now()),
                        id=kill_id
                    ),
                    True
                )
