window.onload = function(e) {
    $('#main').hide();

    var isShown = false;
    var currentMoney = 0;
    var str = "00000000000";
    var gangNames = [
        "Ballas",
        "Famillies",
        "Vagos",
        "Triads",
    ];
    
    window.addEventListener("message", (event) => {
        var item = event.data;
        if (item !== undefined) {
            switch(item.type) {
                case 'ON_STATE':
                    if(item.display === true) {
                        $('#main').show();
                        isShown = true;
                    } else {
                        $('#main').hide();
                        isShown = false;
                    }
                    if (item.gid != undefined) {
                        $('#gname').html(gangNames[item.gid-1])
                    }
                    break;
                case 'ON_UPDATE':
                    if(item.money !== undefined) {
                        changeMoneyBy(item.money);
                    }
                    break;
                case 'ON_SET':
                    if(item.money !== undefined) {
                        currentMoney = item.money;
                        var strToShow = str.substr(0, str.length - currentMoney.toString().length) + currentMoney;
                        $('#money').text(strToShow);
                    }
                    break;
                default:
                    break;
            }
        }
    });

    var que = [];
    var interval = null;
    var moneyChanged = 0;
    var speed = 0.5;

    window.changeMoneyBy = function(money) {
        que.unshift(money);
        if (interval == null) {
            interval = this.setInterval(intervalMoneyChange, speed);
        }
    };

    window.intervalMoneyChange = function() {
        var toChange = 0;
        
        if (Math.abs(que[que.length - 1]) - moneyChanged > 1000) toChange = 1000;
        else if (Math.abs(que[que.length - 1]) - moneyChanged > 100) toChange = 100;
        else toChange = 1;
        
        if (que[que.length - 1] > 0) {
            currentMoney += toChange;
        } else {
            currentMoney -= toChange;
        }
        
        moneyChanged += toChange;

        var strToShow = str.substr(0, str.length - currentMoney.toString().length) + currentMoney;
        $('#money').text(strToShow);

        if (moneyChanged >= Math.abs(que[que.length - 1])) {
            que.pop();

            clearInterval(interval);

            if (que.length > 0) {
                interval = setInterval(intervalMoneyChange, speed);
            } else {
                interval = null;
            }

            moneyChanged = 0;
        }
    }

    function updateTime() {
        var d = new Date();
        var h = d.getHours().toString().length < 2 ? '0' + d.getHours() : d.getHours(); 
        var m = d.getMinutes().toString().length < 2 ? '0' + d.getMinutes() : d.getMinutes(); 
        var s = d.getSeconds().toString().length < 2 ? '0' + d.getSeconds() : d.getSeconds(); 
        $('#time').text(h + ':' + m);
        $('#sec').text(s);
    }

    updateTime();
    setInterval(updateTime, 1000);
}