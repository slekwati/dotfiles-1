{ ... }: {
  services.home-assistant.config = {
    automation = [{
      alias = "IPhone battery warning";
      trigger = {
        platform = "numeric_state";
        entity_id = "sensor.beatrice_battery_level";
        below = 30;
        for = "00:10:00";
      };
      condition = {
        condition = "template";
        value_template = ''{{ state_attr("device_tracker.beatrice_icloud", "battery_status") == "NotCharging" }}'';
      };
      action =
        let
          msg = ''Iphone only got {{ state_attr("device_tracker.beatrice_icloud", "battery") | round(1) }}% battery left'';
        in
        [{
          service = "notify.mobile_app_beatrice";
          data_template.message = msg;
        }
          {
            service = "notify.pushover";
            data_template.message = msg;
          }];
    }
      {
        alias = "Herbert battery warning";
        trigger = {
          platform = "numeric_state";
          entity_id = "sensor.herbert_battery_state";
          below = 30;
          for = "00:10:00";
        };
        condition = {
          condition = "template";
          value_template = ''{{ state_attr("device_tracker.herbert", "battery_status") == "NotCharging" }}'';
        };
        action =
          let
            msg = ''Herbert only got {{ state_attr("device_tracker.herbert", "battery") | round(1) }}% battery left'';
          in
          [{
            service = "notify.mobile_app_beatrice";
            data_template.message = msg;
          }
            {
              service = "notify.pushover";
              data_template.message = msg;
            }];
      }
      {
        alias = "Apple watch battery warning";
        trigger = {
          platform = "numeric_state";
          entity_id = "sensor.shannans_apple_watch_battery_state";
          below = 30;
          for = "00:10:00";
        };
        condition = {
          condition = "template";
          value_template = ''{{ state_attr("device_tracker.shannans_apple_watch", "battery_status") == "NotCharging" }}'';
        };
        action =
          let
            msg = ''Apple watch only got {{ state_attr("device_tracker.shannans_apple_watch", "battery") | round(1) }}% battery left'';
          in
          [{
            service = "notify.mobile_app_beatrice";
            data_template.message = msg;
          }
            {
              service = "notify.pushover";
              data_template.message = msg;
            }];
      }
      {
        alias = "Apple watch wearing reminder notification";
        trigger = {
          platform = "time";
          at = "8:30:00";
        };
        condition = {
          condition = "and";
          conditions = [{
            condition = "time";
            weekday = [ "mon" "tue" "wed" "thu" "fri" ];
          }
            {
              condition = "template";
              value_template = ''{{ state_attr("device_tracker.shannans_apple_watch", "battery_status") == "Charging" }}'';
            }];
        };
        action = [{
          service = "notify.mobile_app_beatrice";
          data_template.message = ''Apple watch is still on charge ({{ state_attr("device_tracker.shannans_apple_watch", "battery") | round(1) }}%)'';
        }];
      }
      {
        alias = "Apple watch charged notification";
        trigger = {
          platform = "numeric_state";
          entity_id = "sensor.shannans_apple_watch_battery_state";
          above = 95;
          for = "00:10:00";
        };
        condition = {
          condition = "template";
          value_template = ''{{ state_attr("device_tracker.shannans_apple_watch", "battery_status") != "NotCharging" }}'';
        };
        action = [{
          service = "notify.mobile_app_beatrice";
          data_template.message = ''Apple watch was charged up to {{ state_attr("device_tracker.shannans_apple_watch", "battery") | round(1) }}%'';
        }];
      }
      {
        alias = "Redmi battery warnings";

        trigger = {
          platform = "numeric_state";
          entity_id = "sensor.redmi_note_5_battery_level";
          below = 30;
          for = "00:10:00";
        };
        condition = {
          condition = "template";
          value_template = ''{{ states("sensor.redmi_note_5_battery_state") == "discharging"  }}'';
        };
        action = [{
          service = "notify.pushover";
          data_template.message = ''Redmi only has {{ states("sensor.redmi_note_5_battery_level")  }}% battery left'';
        }];
      }
      {
        alias = "Redmi charged notification";
        trigger = {
          platform = "numeric_state";
          entity_id = "sensor.redmi_note_5_battery_level";
          above = 95;
          for = "00:10:00";
        };
        condition = {
          condition = "template";
          value_template = ''{{ states("sensor.redmi_note_5_battery_state") != "discharging" }}'';
        };
        action = [{
          service = "notify.pushover";
          data_template.message = ''Redmi was charged up {{ states("sensor.redmi_note_5_battery_level") }}%'';
        }];
      }];
  };
}
