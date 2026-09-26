import { writeFileSync } from "node:fs";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";

const buildSyntheticSql = function buildSyntheticSql() {
  const SEED = 20260926;
  const DAY = 86400000, HOUR = 3600000, MIN = 60000;
  const START = Date.UTC(2026,0,1), END = Date.UTC(2026,5,30,23,59,59);

  function rngFactory(a){return function(){let t=a+=0x6D2B79F5;t=Math.imul(t^(t>>>15),t|1);t^=t+Math.imul(t^(t>>>7),t|61);return((t^(t>>>14))>>>0)/4294967296;}}
  const rng=rngFactory(SEED);
  const ri=(a,b)=>Math.floor(rng()*(b-a+1))+a;
  const pick=a=>a[ri(0,a.length-1)];
  const iso=ms=>new Date(ms).toISOString();
  const date=ms=>iso(ms).slice(0,10);
  const pad=(n,w=4)=>String(n).padStart(w,"0");
  const q=v=>v===null||v===undefined||v===""?"NULL":typeof v==="boolean"?(v?"TRUE":"FALSE"):typeof v==="number"?String(v):`'${String(v).replace(/'/g,"''")}'`;
  const insert=(table,cols,rows)=>{
    if(!rows.length)return "";
    const vals=rows.map(r=>`(${cols.map(c=>q(r[c])).join(", ")})`).join(",\n");
    return `INSERT INTO ${table} (${cols.join(", ")}) VALUES\n${vals};\n`;
  };

  const users=[],profiles=[],tasks=[],routines=[],routine_items=[],routine_checkins=[],routine_item_checkins=[],billing_subscriptions=[],acquisition_touches=[],product_events=[],subscription_revenue=[];
  const billing_plans=[
    {plan_id:"PLAN_MONTHLY",plan_key:"monthly_synthetic",interval_unit:"month",interval_count:1,trial_days:14,active:true},
    {plan_id:"PLAN_ANNUAL",plan_key:"annual_synthetic",interval_unit:"year",interval_count:1,trial_days:14,active:true}
  ];
  const channels=[
    ["organic_social","instagram","organic","always_on_content",0.73],
    ["paid_social","meta","paid_social","launch_interest",0.58],
    ["search","google","organic_search","none",0.77],
    ["referral","user_referral","referral","referral_loop",0.84],
    ["direct","direct","direct","none",0.66],
    ["partnership","partner","partnership","creator_partner",0.75]
  ];
  let taskN=1,routineN=1,itemN=1,checkN=1,itemCheckN=1,eventN=1,subN=1;
  const meta=[];

  const addEvent=(user_id,event_name,occurred_at,surface,object_type="",object_id="")=>{
    if(occurred_at>END)return;
    product_events.push({event_id:`EVT_${pad(eventN++,6)}`,user_id,event_name,occurred_at:iso(occurred_at),event_date:date(occurred_at),surface,object_type,object_id,properties_json:'{"synthetic":true}'});
  };

  for(let i=1;i<=80;i++){
    const user_id=`USR_${pad(i)}`;
    const signup=START+ri(0,115)*DAY+ri(8,21)*HOUR+ri(0,59)*MIN;
    const market=rng()<0.72?"Brazil":"International";
    const locale=market==="Brazil"?(rng()<0.92?"pt-BR":"en-US"):"en-US";
    const timezone=market==="Brazil"?"America/Sao_Paulo":"UTC";
    const ch=channels[ri(0,channels.length-1)];
    const onboarding=rng()<0.88;
    const activated=onboarding&&rng()<ch[4];
    const routineAdopted=activated&&rng()<0.60;
    const ai=activated&&rng()<0.46;
    const trial=activated&&rng()<0.58;
    const paid=trial&&rng()<((ch[0]==="referral"||ch[0]==="search")?0.50:0.40);
    const churn=paid&&rng()<0.16;
    users.push({user_id,created_at:iso(signup),is_anonymous:false});
    profiles.push({user_id,locale,timezone,onboarding_completed:onboarding,is_paid:false,daily_focus_updated_at:ai?iso(Math.min(END,signup+ri(4,35)*DAY)):"",ai_personalization_enabled:ai,market_key:market});
    meta.push({user_id,signup,market,ch,onboarding,activated,routineAdopted,ai,trial,paid,churn});
    if(onboarding)addEvent(user_id,"onboarding_completed",signup+ri(15,60)*MIN,"Onboarding","profile",user_id);

    let firstCore=null;
    const nTasks=activated?ri(7,12):ri(2,4);
    for(let j=1;j<=nTasks;j++){
      let created=j===1&&activated?signup+ri(2,7)*HOUR:signup+ri(0,105)*DAY+ri(0,18)*HOUR;
      if(created>END-DAY)continue;
      const task_id=`TSK_${pad(taskN++,6)}`;
      const viaToday=j===1&&activated?true:rng()<0.60;
      const completed=j===1&&activated?true:rng()<(activated?0.68:0.12);
      const todayAdded=viaToday?created+ri(10,150)*MIN:null;
      if(todayAdded)addEvent(user_id,"task_added_to_today",todayAdded,"Today","task",task_id);
      let completedAt=null,status=rng()<0.22?"doing":"todo";
      if(completed){
        const c=created+ri(2,60)*HOUR;
        if(c<=END){completedAt=c;status="done";addEvent(user_id,"task_completed",c,viaToday?"Today":"Tasks","task",task_id);if(viaToday&&firstCore===null)firstCore=c;}
      }
      tasks.push({
        task_id,user_id,created_at:iso(created),status,priority:pick(["low","medium","medium","high","urgent"]),
        due_date:date(Math.min(END,created+ri(0,6)*DAY)),completed_at:completedAt?iso(completedAt):"",
        is_deleted:rng()<0.02,area:pick(["Work","Personal","Mind","Body","General"]),
        is_today:status!=="done"&&created>END-10*DAY&&rng()<0.35,today_added_at:todayAdded?iso(todayAdded):"",parent_task_id:""
      });
    }

    if(routineAdopted){
      const nr=rng()<0.75?1:2;
      for(let r=0;r<nr;r++){
        const routine_id=`RTN_${pad(routineN++,5)}`;
        const created=signup+ri(3,12)*DAY+ri(6,18)*HOUR;
        if(created>END-DAY)continue;
        routines.push({routine_id,user_id,created_at:iso(created),period:pick(["daily","daily","weekly","custom"]),is_active:true,area:pick(["Personal","Mind","Body","General"]),time_of_day:pick(["morning","afternoon","evening"]),goal_duration:pick([10,15,20,30]),start_date:date(created)});
        const items=[];
        const ni=ri(2,3);
        for(let k=0;k<ni;k++){const id=`RTI_${pad(itemN++,6)}`;items.push(id);routine_items.push({routine_item_id:id,routine_id,user_id,created_at:iso(created+k*MIN),sort_order:k+1,is_active:true});}
        let cursor=created+DAY;
        let made=0;
        while(cursor<=END&&made<16){
          if(rng()<0.72){
            const routine_checkin_id=`RCI_${pad(checkN++,6)}`;
            const at=cursor+ri(6,21)*HOUR;if(at>END)break;
            routine_checkins.push({routine_checkin_id,user_id,routine_id,checkin_date:date(at),created_at:iso(at)});
            for(const routine_item_id of items){
              const done=rng()<0.90;
              routine_item_checkins.push({routine_item_checkin_id:`RIC_${pad(itemCheckN++,7)}`,user_id,routine_checkin_id,routine_item_id,is_done:done,done_at:done?iso(at+ri(1,20)*MIN):""});
            }
            const evAt=at+ri(3,20)*MIN;const surf=rng()<0.68?"Today":"Routines";
            addEvent(user_id,"routine_completed",evAt,surf,"routine",routine_id);
            if(surf==="Today"&&firstCore===null)firstCore=evAt;
            made++;
          }
          cursor+=ri(2,4)*DAY;
        }
      }
    }

    if(ai){
      for(let a=0;a<ri(3,7);a++){
        const t=signup+ri(6,125)*DAY+ri(8,21)*HOUR;if(t>END)continue;
        addEvent(user_id,a%3===0?"weekly_insight_viewed":a%2===0?"daily_reflection_viewed":"daily_focus_viewed",t,"AI","ai_experience","");
      }
    }

    if(trial){
      const base=firstCore??signup+DAY;
      const paywall=Math.min(END,base+ri(1,5)*DAY);addEvent(user_id,"paywall_viewed",paywall,"Paywall","","");
      const ts=paywall+ri(15,120)*MIN;if(ts<=END){
        addEvent(user_id,"trial_started",ts,"Paywall","","");
        const te=ts+14*DAY,plan_id=rng()<0.28?"PLAN_ANNUAL":"PLAN_MONTHLY",provider=market==="International"?"stripe":(rng()<0.55?"google_play":"stripe"),subscription_id=`SUB_${pad(subN++,5)}`;
        let lifecycle=te>END?"trialing":"expired",starts_at="",canceled_at="",current_period_starts_at="",current_period_ends_at="",auto_renews=false;
        if(paid&&te<=END){
          starts_at=iso(te);lifecycle="active";auto_renews=true;addEvent(user_id,"subscription_activated",te,"Billing","subscription",subscription_id);
          const cc=te+ri(35,105)*DAY;
          if(churn&&cc<=END){canceled_at=iso(cc);lifecycle="canceled";auto_renews=false;addEvent(user_id,"subscription_canceled",cc,"Billing","subscription",subscription_id);}
          const ref=canceled_at?Date.parse(canceled_at):END,d=new Date(ref),ps=Date.UTC(d.getUTCFullYear(),d.getUTCMonth(),1),pe=plan_id==="PLAN_MONTHLY"?Date.UTC(d.getUTCFullYear(),d.getUTCMonth()+1,1):Date.UTC(d.getUTCFullYear()+1,d.getUTCMonth(),1);
          current_period_starts_at=iso(ps);current_period_ends_at=iso(pe);
          profiles[profiles.length-1].is_paid=lifecycle==="active";
          let m=new Date(te);m=Date.UTC(m.getUTCFullYear(),m.getUTCMonth(),1);let first=true;const end=canceled_at?Date.parse(canceled_at):END;
          while(m<=Date.UTC(new Date(end).getUTCFullYear(),new Date(end).getUTCMonth(),1)){
            subscription_revenue.push({subscription_id,user_id,plan_id,month_start_date:date(m),currency:"USD",gross_recurring_amount:plan_id==="PLAN_MONTHLY"?9:(first?72:0),normalized_mrr:plan_id==="PLAN_MONTHLY"?9:6,is_new_mrr:first,is_active_paid:true});
            first=false;const md=new Date(m);m=Date.UTC(md.getUTCFullYear(),md.getUTCMonth()+1,1);
          }
        }
        billing_subscriptions.push({subscription_id,user_id,plan_id,provider,lifecycle_state:lifecycle,starts_at,trial_starts_at:iso(ts),trial_ends_at:iso(te),current_period_starts_at,current_period_ends_at,canceled_at,auto_renews});
      }
    }
  }

  for(let v=1;v<=300;v++){
    let user_id="",occurred_at,market,ch;
    if(v<=meta.length){const u=meta[v-1];user_id=u.user_id;occurred_at=Math.max(START,u.signup-ri(10,220)*MIN);market=u.market;ch=u.ch;}
    else{occurred_at=START+ri(0,118)*DAY+ri(7,22)*HOUR;market=rng()<0.72?"Brazil":"International";ch=channels[ri(0,channels.length-1)];}
    acquisition_touches.push({acquisition_id:`ACQ_${pad(v,5)}`,user_id,occurred_at:iso(occurred_at),channel:ch[0],source:ch[1],medium:ch[2],campaign:ch[3],landing_page:market==="Brazil"?"/pt-br":"/en",market_key:market,is_qualified_visit:true,converted_to_signup:Boolean(user_id)});
  }

  const ids=new Set(users.map(x=>x.user_id)),rids=new Set(routines.map(x=>x.routine_id)),iids=new Set(routine_items.map(x=>x.routine_item_id)),cids=new Set(routine_checkins.map(x=>x.routine_checkin_id)),pids=new Set(billing_plans.map(x=>x.plan_id)),sids=new Set(billing_subscriptions.map(x=>x.subscription_id));
  const checks=[
    ["profiles match users",profiles.length===users.length],
    ["task user keys",tasks.every(x=>ids.has(x.user_id))],
    ["routine keys",routines.every(x=>ids.has(x.user_id))],
    ["routine item keys",routine_items.every(x=>rids.has(x.routine_id)&&ids.has(x.user_id))],
    ["routine checkin keys",routine_checkins.every(x=>rids.has(x.routine_id)&&ids.has(x.user_id))],
    ["routine item checkin keys",routine_item_checkins.every(x=>cids.has(x.routine_checkin_id)&&iids.has(x.routine_item_id)&&ids.has(x.user_id))],
    ["subscription keys",billing_subscriptions.every(x=>ids.has(x.user_id)&&pids.has(x.plan_id))],
    ["revenue keys",subscription_revenue.every(x=>sids.has(x.subscription_id)&&ids.has(x.user_id)&&pids.has(x.plan_id))],
    ["converted acquisition keys",acquisition_touches.filter(x=>x.converted_to_signup).every(x=>ids.has(x.user_id))],
    ["trial chronology",billing_subscriptions.every(x=>Date.parse(x.trial_ends_at)>=Date.parse(x.trial_starts_at))]
  ];
  if(!checks.every(x=>x[1]))throw new Error("Validation failed");

  const schema=`-- PROTANNI synthetic analytical dataset\n-- Fully synthetic. No production records were used.\nDROP TABLE IF EXISTS subscription_revenue;\nDROP TABLE IF EXISTS product_events;\nDROP TABLE IF EXISTS acquisition_touches;\nDROP TABLE IF EXISTS billing_subscriptions;\nDROP TABLE IF EXISTS billing_plans;\nDROP TABLE IF EXISTS routine_item_checkins;\nDROP TABLE IF EXISTS routine_checkins;\nDROP TABLE IF EXISTS routine_items;\nDROP TABLE IF EXISTS routines;\nDROP TABLE IF EXISTS tasks;\nDROP TABLE IF EXISTS profiles;\nDROP TABLE IF EXISTS users;\n\nCREATE TABLE users (user_id VARCHAR PRIMARY KEY, created_at TIMESTAMPTZ NOT NULL, is_anonymous BOOLEAN NOT NULL);\nCREATE TABLE profiles (user_id VARCHAR PRIMARY KEY, locale VARCHAR, timezone VARCHAR, onboarding_completed BOOLEAN NOT NULL, is_paid BOOLEAN NOT NULL, daily_focus_updated_at TIMESTAMPTZ, ai_personalization_enabled BOOLEAN NOT NULL, market_key VARCHAR);\nCREATE TABLE tasks (task_id VARCHAR PRIMARY KEY, user_id VARCHAR NOT NULL, created_at TIMESTAMPTZ NOT NULL, status VARCHAR NOT NULL, priority VARCHAR NOT NULL, due_date DATE, completed_at TIMESTAMPTZ, is_deleted BOOLEAN NOT NULL, area VARCHAR, is_today BOOLEAN NOT NULL, today_added_at TIMESTAMPTZ, parent_task_id VARCHAR);\nCREATE TABLE routines (routine_id VARCHAR PRIMARY KEY, user_id VARCHAR NOT NULL, created_at TIMESTAMPTZ NOT NULL, period VARCHAR NOT NULL, is_active BOOLEAN NOT NULL, area VARCHAR, time_of_day VARCHAR, goal_duration INTEGER, start_date DATE);\nCREATE TABLE routine_items (routine_item_id VARCHAR PRIMARY KEY, routine_id VARCHAR NOT NULL, user_id VARCHAR NOT NULL, created_at TIMESTAMPTZ NOT NULL, sort_order INTEGER NOT NULL, is_active BOOLEAN NOT NULL);\nCREATE TABLE routine_checkins (routine_checkin_id VARCHAR PRIMARY KEY, user_id VARCHAR NOT NULL, routine_id VARCHAR NOT NULL, checkin_date DATE NOT NULL, created_at TIMESTAMPTZ NOT NULL);\nCREATE TABLE routine_item_checkins (routine_item_checkin_id VARCHAR PRIMARY KEY, user_id VARCHAR NOT NULL, routine_checkin_id VARCHAR NOT NULL, routine_item_id VARCHAR NOT NULL, is_done BOOLEAN NOT NULL, done_at TIMESTAMPTZ);\nCREATE TABLE billing_plans (plan_id VARCHAR PRIMARY KEY, plan_key VARCHAR NOT NULL, interval_unit VARCHAR NOT NULL, interval_count INTEGER NOT NULL, trial_days INTEGER NOT NULL, active BOOLEAN NOT NULL);\nCREATE TABLE billing_subscriptions (subscription_id VARCHAR PRIMARY KEY, user_id VARCHAR NOT NULL, plan_id VARCHAR NOT NULL, provider VARCHAR NOT NULL, lifecycle_state VARCHAR NOT NULL, starts_at TIMESTAMPTZ, trial_starts_at TIMESTAMPTZ NOT NULL, trial_ends_at TIMESTAMPTZ NOT NULL, current_period_starts_at TIMESTAMPTZ, current_period_ends_at TIMESTAMPTZ, canceled_at TIMESTAMPTZ, auto_renews BOOLEAN NOT NULL);\nCREATE TABLE acquisition_touches (acquisition_id VARCHAR PRIMARY KEY, user_id VARCHAR, occurred_at TIMESTAMPTZ NOT NULL, channel VARCHAR NOT NULL, source VARCHAR NOT NULL, medium VARCHAR NOT NULL, campaign VARCHAR NOT NULL, landing_page VARCHAR NOT NULL, market_key VARCHAR NOT NULL, is_qualified_visit BOOLEAN NOT NULL, converted_to_signup BOOLEAN NOT NULL);\nCREATE TABLE product_events (event_id VARCHAR PRIMARY KEY, user_id VARCHAR NOT NULL, event_name VARCHAR NOT NULL, occurred_at TIMESTAMPTZ NOT NULL, event_date DATE NOT NULL, surface VARCHAR NOT NULL, object_type VARCHAR, object_id VARCHAR, properties_json VARCHAR);\nCREATE TABLE subscription_revenue (subscription_id VARCHAR NOT NULL, user_id VARCHAR NOT NULL, plan_id VARCHAR NOT NULL, month_start_date DATE NOT NULL, currency VARCHAR NOT NULL, gross_recurring_amount DECIMAL(10,2) NOT NULL, normalized_mrr DECIMAL(10,2) NOT NULL, is_new_mrr BOOLEAN NOT NULL, is_active_paid BOOLEAN NOT NULL);\n\n`;
  const sql=schema+
    insert("users",["user_id","created_at","is_anonymous"],users)+
    insert("profiles",["user_id","locale","timezone","onboarding_completed","is_paid","daily_focus_updated_at","ai_personalization_enabled","market_key"],profiles)+
    insert("tasks",["task_id","user_id","created_at","status","priority","due_date","completed_at","is_deleted","area","is_today","today_added_at","parent_task_id"],tasks)+
    insert("routines",["routine_id","user_id","created_at","period","is_active","area","time_of_day","goal_duration","start_date"],routines)+
    insert("routine_items",["routine_item_id","routine_id","user_id","created_at","sort_order","is_active"],routine_items)+
    insert("routine_checkins",["routine_checkin_id","user_id","routine_id","checkin_date","created_at"],routine_checkins)+
    insert("routine_item_checkins",["routine_item_checkin_id","user_id","routine_checkin_id","routine_item_id","is_done","done_at"],routine_item_checkins)+
    insert("billing_plans",["plan_id","plan_key","interval_unit","interval_count","trial_days","active"],billing_plans)+
    insert("billing_subscriptions",["subscription_id","user_id","plan_id","provider","lifecycle_state","starts_at","trial_starts_at","trial_ends_at","current_period_starts_at","current_period_ends_at","canceled_at","auto_renews"],billing_subscriptions)+
    insert("acquisition_touches",["acquisition_id","user_id","occurred_at","channel","source","medium","campaign","landing_page","market_key","is_qualified_visit","converted_to_signup"],acquisition_touches)+
    insert("product_events",["event_id","user_id","event_name","occurred_at","event_date","surface","object_type","object_id","properties_json"],product_events)+
    insert("subscription_revenue",["subscription_id","user_id","plan_id","month_start_date","currency","gross_recurring_amount","normalized_mrr","is_new_mrr","is_active_paid"],subscription_revenue);

  const counts={users:users.length,profiles:profiles.length,tasks:tasks.length,routines:routines.length,routine_items:routine_items.length,routine_checkins:routine_checkins.length,routine_item_checkins:routine_item_checkins.length,billing_plans:billing_plans.length,billing_subscriptions:billing_subscriptions.length,acquisition_touches:acquisition_touches.length,product_events:product_events.length,subscription_revenue:subscription_revenue.length};
  return {sql,counts,checks,seed:SEED};
};
const data = buildSyntheticSql();
const outDir = dirname(fileURLToPath(import.meta.url));
writeFileSync(join(outDir, "synthetic_dataset.sql"), data.sql, "utf8");
console.log("Generated synthetic_dataset.sql", data.counts);
