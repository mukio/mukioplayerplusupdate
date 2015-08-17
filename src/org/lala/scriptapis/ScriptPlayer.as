package org.lala.scriptapis
{
    import com.longtailvideo.jwplayer.player.Player;
    
    import org.lala.plugins.CommentView;
    import org.lala.utils.CommentConfig;

    public class ScriptPlayer implements IScript
    {
        private var _player:Player;
        private var _config:CommentConfig;
        public function ScriptPlayer(player:Player)
        {
            _player = player;
            _config = CommentConfig.getInstance();
        }
        
        public function get help():String
        {
            return "播放器接口Player:\n" +
                "play():void\n" +
                "pause():void\n" +
                "seek(time:Number):void,time秒数\n" +
                "time:Number,当前时间,秒数";
        }
        
        public function play():void
        {
            if(!_config.isPlayerControlApiEnable)
            {
                return;
            }
            _player.play();
        }
        
        public function pause():void
        {
            if(!_config.isPlayerControlApiEnable)
            {
                return;
            }
            _player.pause();
        }
        
        public function seek(time:Number):void
        {
            if(!_config.isPlayerControlApiEnable)
            {
                return;
            }
            _player.seek(time);
        }
        
        public function get time():Number
        {
            return CommentView.getInstance().stime;
        }
    }
}