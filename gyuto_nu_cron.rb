#!/usr/bin/ruby
# -*- coding: utf-8 -*-

#
#   gyuto_nu_cron.rb
#
#  bot core for @gyuto_nu
#  Copyright 2012 @YVT, all rights reserved.
#

require 'date';
require 'uri';

$KCODE='u'

$SUPERTWEET_USER='gyuto_nu'
$SUPERTWEET_PASSWORD='Supertweetのパスワードをここに挿入'

$terms=[
{"due_name" => "ぎゅっとe第1回締切日",
	"start_date" => Date::new(2012, 10, 1),
	"due_date" => Date::new(2012, 11, 22),
	"quota" => {"Reading" => 20,
		"Listening" => 350}},
{"due_name" => "ぎゅっとe第2回締切日",
	"start_date" => Date::new(2012, 11, 23),
	"due_date" => Date::new(2012, 12, 21),
	"quota" => {"Reading" => 20,
		"Listening" => 350}},
{"due_name" => "ぎゅっとe第3回締切日",
	"start_date" => Date::new(2012, 12, 22),
	"due_date" => Date::new(2013, 1, 25),
	"quota" => {"Reading" => 16,
		"Listening" => 308}}
];

$captchaTexts=[
	"今日もお疲れさま！",
	"眠くなってない？",
	"たまには指の運動をしてみたら？",
	"頑張ってますか〜？",
	"順調に進んでる？",
	"お疲れさま〜っ！",
	"継続は力なり。続けて頑張ろう。"
];

$today=Date::today;
#$today=Date::new(2012,7,24)

def chooseCaptchaText
	return $captchaTexts[rand($captchaTexts.length)];
end

def accumlateQuotaForTerm(term)
	quota={"Reading" => 0,
		"Listening" => 0}
	$terms.each do |t|
		localQuota=t["quota"];
		localQuota.each do |key, val|
			quota[key]+=val
		end
		return quota if t["due_name"] == term["due_name"]
	end
	return nil
end

def accumlateQuotaBeforeTerm(term)
	quota={"Reading" => 0,
		"Listening" => 0}
	$terms.each do |t|
		return quota if t["due_name"] == term["due_name"]
		localQuota=t["quota"];
		localQuota.each do |key, val|
			quota[key]+=val
		end
		
	end
	return nil
end

def interpolateQuota(quota1, quota2, per)
	quota={}
	quota1.each do |key, val1|
		val2=quota2[key]
		quota[key]=val1+(val2-val1)*per
	end
	return quota
end

def stringForQuota(quota)
	return "Reading #{quota['Reading'].ceil}問、Listening #{quota['Listening'].ceil}問"
end

def termForDate(dt)
	$terms.each do |t|
		return t if dt<=t["due_date"]
	end
	return nil
end

def currentTerm
	return termForDate($today)
end

def tweet(text)
	#puts text
	cmd='curl -u ' + $SUPERTWEET_USER + ':' + $SUPERTWEET_PASSWORD + ' -d "status='+URI.encode(text)+'" http://api.supertweet.net/1.1/statuses/update.json 2>/dev/null'
	cmd+=' --connect-timeout 10 --retry 30 --retry-delay 120'
	#puts cmd
	res=`#{cmd}`
	#puts res
end



def doCron
	term=currentTerm
	
	if term == nil
		
	else # $term == nil
		
		txt=chooseCaptchaText
		
		dayname="#{$today.month}月#{$today.day}日"
		
		if $today == term["due_date"] 
			txt+="今日#{dayname}は#{term['due_name']}だよ。"
			
			nextTerm=termForDate($today+1)
			
			if nextTerm == nil
				txt+="本日でぎゅっとeは終了です。半年間お疲れさまでした〜っ！"
			else
				txt+="次の#{nextTerm['due_name']}は"
				daysLeft=nextTerm["due_date"]-$today;
				txt+="#{daysLeft}日後、目標は累計"
				quota=accumlateQuotaForTerm(nextTerm)
				txt+=" #{stringForQuota(quota)}です。ハイ、明日からも頑張れ〜っ！"
			end
		else
			
			txt+="今日は#{dayname}です。#{term['due_name']}まであと"
			period=term["due_date"]-term["start_date"]
			daysLeft=term["due_date"]-$today;
			txt+="#{daysLeft}日、今日の目標は累計"
			quota2=accumlateQuotaBeforeTerm(term)
			quota1=accumlateQuotaForTerm(term)
			quota=interpolateQuota(quota1, quota2, (daysLeft-1)/(period))
			txt+=" #{stringForQuota(quota)}です。"
			
		end # $today == term["due_date"] 
		
		tweet(txt)
			
	end # $term == nil
	
	

end

doCron

