import Foundation

class Language {
    
    // 测试方法：检查本地化是否正常工作 (仅在DEBUG模式下可用)
    static func testLocalization() {
        #if DEBUG
        print("=== Language Localization Test ===")
        print("Current language: \(LocalizationManager.shared.currentLanguage.rawValue)")
        print("Current bundle: \(LocalizationManager.shared.currentBundle?.bundlePath ?? "nil")")
        
        // 测试关键的首页本地化key
        let testKeys = [
            "home_action_identify",
            "home_action_record",
            "home_vip_banner_text",
            "home_your_daily_stone",
            "home_stones_near_you"
        ]
        
        for key in testKeys {
            let localized = LocalizationManager.shared.localizedString(for: key)
            let isLocalized = localized != key
            print("🔍 '\(key)' -> '\(localized)' [\(isLocalized ? "✅ LOCALIZED" : "❌ NOT LOCALIZED")]")
        }
        
        // 测试直接从bundle读取
        print("\n=== Direct Bundle Test ===")
        if let bundle = LocalizationManager.shared.currentBundle {
            print("Bundle path: \(bundle.bundlePath)")
            let testKey = "home_action_identify"
            let directResult = bundle.localizedString(forKey: testKey, value: testKey, table: nil)
            print("Direct bundle lookup '\(testKey)': '\(directResult)'")
        }
        
        // 测试主bundle
        print("\n=== Main Bundle Test ===")
        let mainBundleResult = Bundle.main.localizedString(forKey: "home_action_identify", value: "home_action_identify", table: nil)
        print("Main bundle lookup 'home_action_identify': '\(mainBundleResult)'")
        
        print("=== End Test ===\n")
        #endif
    }
    
    // 应用名称和标签栏
    static var app_name: String { return LocalizationManager.shared.localizedString(for: "app_name") }
    static var tab_bar_home: String { return LocalizationManager.shared.localizedString(for: "tab_bar_home") }
    static var tab_bar_profile: String { return LocalizationManager.shared.localizedString(for: "tab_bar_profile") }
    
    // 标题
    static var title_home: String { return LocalizationManager.shared.localizedString(for: "title_home") }
    static var title_dashboard: String { return LocalizationManager.shared.localizedString(for: "title_dashboard") }
    static var title_notifications: String { return LocalizationManager.shared.localizedString(for: "title_notifications") }
    
    // 启动页
    static var splash_start_now: String { return LocalizationManager.shared.localizedString(for: "splash_start_now") }
    static var splash_first_launch_slogan: String { return LocalizationManager.shared.localizedString(for: "splash_first_launch_slogan") }
    
    // 通用文本
    static var text_policy_tapping_continue: String { return LocalizationManager.shared.localizedString(for: "text_policy_tapping_continue") }
    static var text_terms_of_use: String { return LocalizationManager.shared.localizedString(for: "text_terms_of_use") }
    static var text_privacy_policy: String { return LocalizationManager.shared.localizedString(for: "text_privacy_policy") }
    static var text_refund_policy: String { return LocalizationManager.shared.localizedString(for: "text_refund_policy") }
    static var text_contact_us: String { return LocalizationManager.shared.localizedString(for: "text_contact_us") }
    static var text_customer_service: String { return LocalizationManager.shared.localizedString(for: "text_customer_service") }
    static var text_email_prefix: String { return LocalizationManager.shared.localizedString(for: "text_email_prefix") }
    static var text_next: String { return LocalizationManager.shared.localizedString(for: "text_next") }
    static var text_copied: String { return LocalizationManager.shared.localizedString(for: "text_copied") }
    static var text_continue: String { return LocalizationManager.shared.localizedString(for: "text_continue") }
    static var text_cancel: String { return LocalizationManager.shared.localizedString(for: "text_cancel") }
    static var text_game: String { return LocalizationManager.shared.localizedString(for: "text_game") }
    static var text_profile: String { return LocalizationManager.shared.localizedString(for: "text_profile") }
    static var text_yes: String { return LocalizationManager.shared.localizedString(for: "text_yes") }
    static var text_no: String { return LocalizationManager.shared.localizedString(for: "text_no") }
    static var text_maybe_later: String { return LocalizationManager.shared.localizedString(for: "text_maybe_later") }
    static var text_submit: String { return LocalizationManager.shared.localizedString(for: "text_submit") }
    static var text_confirm: String { return LocalizationManager.shared.localizedString(for: "text_confirm") }
    static var text_loading: String { return LocalizationManager.shared.localizedString(for: "text_loading") }
    static var text_view_all: String { return LocalizationManager.shared.localizedString(for: "text_view_all") }
    static var text_try_again: String { return LocalizationManager.shared.localizedString(for: "text_try_again") }
    static var text_save: String { return LocalizationManager.shared.localizedString(for: "text_save") }
    static var text_new: String { return LocalizationManager.shared.localizedString(for: "text_new") }
    static var text_share: String { return LocalizationManager.shared.localizedString(for: "text_share") }
    static var text_common_error_try_again: String { return LocalizationManager.shared.localizedString(for: "text_common_error_try_again") }
    static var text_also_known_as: String { return LocalizationManager.shared.localizedString(for: "text_also_known_as") }
    static var text_scientific_name: String { return LocalizationManager.shared.localizedString(for: "text_scientific_name") }
    static var text_more: String { return LocalizationManager.shared.localizedString(for: "text_more") }
    static var text_images: String { return LocalizationManager.shared.localizedString(for: "text_images") }
    static var text_map: String { return LocalizationManager.shared.localizedString(for: "text_map") }
    static var text_description: String { return LocalizationManager.shared.localizedString(for: "text_description") }
    static var text_ok: String { return LocalizationManager.shared.localizedString(for: "text_ok") }
    static var text_photo: String { return LocalizationManager.shared.localizedString(for: "text_photo") }
    static var text_tips: String { return LocalizationManager.shared.localizedString(for: "text_tips") }
    
    // 首页
    static var home_search_hint: String { return LocalizationManager.shared.localizedString(for: "home_search_hint") }
    static var home_vip_banner_text: String { return LocalizationManager.shared.localizedString(for: "home_vip_banner_text") }
    static var home_action_identify: String { return LocalizationManager.shared.localizedString(for: "home_action_identify") }
    static var home_your_daily_stone: String { return LocalizationManager.shared.localizedString(for: "home_your_daily_stone") }
    static var home_stones_near_you: String { return LocalizationManager.shared.localizedString(for: "home_stones_near_you") }
    static var home_app_usage_title: String { return LocalizationManager.shared.localizedString(for: "home_app_usage_title") }
    static var home_app_usage_desc: String { return LocalizationManager.shared.localizedString(for: "home_app_usage_desc") }
    
    // 调查问卷
    static var survey1_title: String { return LocalizationManager.shared.localizedString(for: "survey1_title") }
    static var survey1_input_name_placeholder: String { return LocalizationManager.shared.localizedString(for: "survey1_input_name_placeholder") }
    
    static var survey2_title: String { return LocalizationManager.shared.localizedString(for: "survey2_title") }
    static var survey2_option_she: String { return LocalizationManager.shared.localizedString(for: "survey2_option_she") }
    static var survey2_option_he: String { return LocalizationManager.shared.localizedString(for: "survey2_option_he") }
    static var survey2_option_they: String { return LocalizationManager.shared.localizedString(for: "survey2_option_they") }
    
    static var survey3_title: String { return LocalizationManager.shared.localizedString(for: "survey3_title") }
    static var survey3_option1: String { return LocalizationManager.shared.localizedString(for: "survey3_option1") }
    static var survey3_option2: String { return LocalizationManager.shared.localizedString(for: "survey3_option2") }
    static var survey3_option3: String { return LocalizationManager.shared.localizedString(for: "survey3_option3") }
    static var survey3_option4: String { return LocalizationManager.shared.localizedString(for: "survey3_option4") }
    static var survey3_option5: String { return LocalizationManager.shared.localizedString(for: "survey3_option5") }
    static var survey3_option6: String { return LocalizationManager.shared.localizedString(for: "survey3_option6") }
    
    static var survey4_title: String { return LocalizationManager.shared.localizedString(for: "survey4_title") }
    
    static var survey5_title: String { return LocalizationManager.shared.localizedString(for: "survey5_title") }
    static var survey5_reset_all_blocked_roles_warning_message: String { return LocalizationManager.shared.localizedString(for: "survey5_reset_all_blocked_roles_warning_message") }
    
    static var survey6_title: String { return LocalizationManager.shared.localizedString(for: "survey6_title") }
    static var survey6_input_name_placeholder: String { return LocalizationManager.shared.localizedString(for: "survey6_input_name_placeholder") }
    
    static var survey7_creating: String { return LocalizationManager.shared.localizedString(for: "survey7_creating") }
    
    // 聊天
    static var text_ai_chat: String { return LocalizationManager.shared.localizedString(for: "text_ai_chat") }
    static var chat_input_bar_placeholder: String { return LocalizationManager.shared.localizedString(for: "chat_input_bar_placeholder") }
    static var chat_error_oops: String { return LocalizationManager.shared.localizedString(for: "chat_error_oops") }
    static var chat_report_bot_response_warning_messasge: String { return LocalizationManager.shared.localizedString(for: "chat_report_bot_response_warning_messasge") }
    static var chat_report_ai_character: String { return LocalizationManager.shared.localizedString(for: "chat_report_ai_character") }
    static var chat_just_report_content: String { return LocalizationManager.shared.localizedString(for: "chat_just_report_content") }
    
    // 欢迎页
    static var welcome_title: String { return LocalizationManager.shared.localizedString(for: "welcome_title") }
    static var welcome_content: String { return LocalizationManager.shared.localizedString(for: "welcome_content") }
    static var welcome_got_it: String { return LocalizationManager.shared.localizedString(for: "welcome_got_it") }
    
    // 举报
    static var report_title: String { return LocalizationManager.shared.localizedString(for: "report_title") }
    static var report_edit_text_hint: String { return LocalizationManager.shared.localizedString(for: "report_edit_text_hint") }
    static var report_success: String { return LocalizationManager.shared.localizedString(for: "report_success") }
    static var report_block_character: String { return LocalizationManager.shared.localizedString(for: "report_block_character") }
    static var report_block_character_warning_message: String { return LocalizationManager.shared.localizedString(for: "report_block_character_warning_message") }
    
    // 个人资料
    static var profile_about_app: String { return LocalizationManager.shared.localizedString(for: "profile_about_app") }
    static var profile_restart_chat: String { return LocalizationManager.shared.localizedString(for: "profile_restart_chat") }
    static var profile_delete_account: String { return LocalizationManager.shared.localizedString(for: "profile_delete_account") }
    
    // 重新开始聊天警告
    static var restart_chat_warning_title: String { return LocalizationManager.shared.localizedString(for: "restart_chat_warning_title") }
    static var restart_chat_warning_content: String { return LocalizationManager.shared.localizedString(for: "restart_chat_warning_content") }
    
    // 删除账户警告
    static var delete_account_warning_title: String { return LocalizationManager.shared.localizedString(for: "delete_account_warning_title") }
    static var delete_account_warning_content: String { return LocalizationManager.shared.localizedString(for: "delete_account_warning_content") }
    
    // 相机权限
    static var camera_permission_request_title: String { return LocalizationManager.shared.localizedString(for: "camera_permission_request_title") }
    static var camera_permission_request_desc: String { return LocalizationManager.shared.localizedString(for: "camera_permission_request_desc") }
    static var camera_permisson_request_button: String { return LocalizationManager.shared.localizedString(for: "camera_permisson_request_button") }
    static var camera_preview_tip: String { return LocalizationManager.shared.localizedString(for: "camera_preview_tip") }
    
    // 设置
    static var settings_title: String { return LocalizationManager.shared.localizedString(for: "settings_title") }
    static var settings_premium_service: String { return LocalizationManager.shared.localizedString(for: "settings_premium_service") }
    static var settings_free: String { return LocalizationManager.shared.localizedString(for: "settings_free") }
    static var settings_set_language: String { return LocalizationManager.shared.localizedString(for: "settings_set_language") }
    static var settings_autosave_photos: String { return LocalizationManager.shared.localizedString(for: "settings_autosave_photos") }
    static var settings_encourage_us: String { return LocalizationManager.shared.localizedString(for: "settings_encourage_us") }
    static var settings_suggestion: String { return LocalizationManager.shared.localizedString(for: "settings_suggestion") }
    static var settings_app_info: String { return LocalizationManager.shared.localizedString(for: "settings_app_info") }
    static var settings_tell_friends: String { return LocalizationManager.shared.localizedString(for: "settings_tell_friends") }
    static var settings_privacy_policy: String { return LocalizationManager.shared.localizedString(for: "settings_privacy_policy") }
    static var settings_terms_of_use: String { return LocalizationManager.shared.localizedString(for: "settings_terms_of_use") }
    static var settings_manage_account: String { return LocalizationManager.shared.localizedString(for: "settings_manage_account") }
    
    // 新增硬编码字符串的本地化key
    static var stone_info_detailed_not_available: String { return LocalizationManager.shared.localizedString(for: "stone_info_detailed_not_available") }
    static var stone_info_additional_characteristics: String { return LocalizationManager.shared.localizedString(for: "stone_info_additional_characteristics") }
    static var stone_info_characteristics: String { return LocalizationManager.shared.localizedString(for: "stone_info_characteristics") }
    static var stone_info_scientific_classification: String { return LocalizationManager.shared.localizedString(for: "stone_info_scientific_classification") }
    static var stone_info_additional_classification: String { return LocalizationManager.shared.localizedString(for: "stone_info_additional_classification") }
    static var stone_info_more: String { return LocalizationManager.shared.localizedString(for: "stone_info_more") }
    
    // 购买相关
    static var purchase_choose_subscription_plan: String { return LocalizationManager.shared.localizedString(for: "purchase_choose_subscription_plan") }
    static var purchase_unlock_premium_features: String { return LocalizationManager.shared.localizedString(for: "purchase_unlock_premium_features") }
    static var purchase_restore_purchases: String { return LocalizationManager.shared.localizedString(for: "purchase_restore_purchases") }
    static var purchase_cancel: String { return LocalizationManager.shared.localizedString(for: "purchase_cancel") }
    static var purchase_user_cancelled: String { return LocalizationManager.shared.localizedString(for: "purchase_user_cancelled") }
    static var purchase_please_wait: String { return LocalizationManager.shared.localizedString(for: "purchase_please_wait") }
    static var purchase_processing: String { return LocalizationManager.shared.localizedString(for: "purchase_processing") }
    static var purchase_success: String { return LocalizationManager.shared.localizedString(for: "purchase_success") }
    static var purchase_success_message: String { return LocalizationManager.shared.localizedString(for: "purchase_success_message") }
    static var purchase_failed: String { return LocalizationManager.shared.localizedString(for: "purchase_failed") }
    static var purchase_error: String { return LocalizationManager.shared.localizedString(for: "purchase_error") }
    static var purchase_retry: String { return LocalizationManager.shared.localizedString(for: "purchase_retry") }
    static var purchase_cancelled: String { return LocalizationManager.shared.localizedString(for: "purchase_cancelled") }
    static var purchase_restoring: String { return LocalizationManager.shared.localizedString(for: "purchase_restoring") }
    static var purchase_loading_products: String { return LocalizationManager.shared.localizedString(for: "purchase_loading_products") }
    static var purchase_unable_to_load_products: String { return LocalizationManager.shared.localizedString(for: "purchase_unable_to_load_products") }
    static var purchase_select_product: String { return LocalizationManager.shared.localizedString(for: "purchase_select_product") }
    static var purchase_already_vip: String { return LocalizationManager.shared.localizedString(for: "purchase_already_vip") }
    static var purchase_restore: String { return LocalizationManager.shared.localizedString(for: "purchase_restore") }
    static var common_ok: String { return LocalizationManager.shared.localizedString(for: "common_ok") }
    static var common_cancel: String { return LocalizationManager.shared.localizedString(for: "common_cancel") }
    static var purchase_no_purchases_to_restore: String { return LocalizationManager.shared.localizedString(for: "purchase_no_purchases_to_restore") }
    static var purchase_check_network_try_again: String { return LocalizationManager.shared.localizedString(for: "purchase_check_network_try_again") }
    static var purchase_premium_feature: String { return LocalizationManager.shared.localizedString(for: "purchase_premium_feature") }
    static var purchase_premium_feature_message: String { return LocalizationManager.shared.localizedString(for: "purchase_premium_feature_message") }
    static var purchase_upgrade_now: String { return LocalizationManager.shared.localizedString(for: "purchase_upgrade_now") }
    static var purchase_maybe_later: String { return LocalizationManager.shared.localizedString(for: "purchase_maybe_later") }
    static var purchase_upgrade_to_premium: String { return LocalizationManager.shared.localizedString(for: "purchase_upgrade_to_premium") }
    static var purchase_premium_user: String { return LocalizationManager.shared.localizedString(for: "purchase_premium_user") }
    static var purchase_free_user: String { return LocalizationManager.shared.localizedString(for: "purchase_free_user") }
    static var purchase_operation_successful: String { return LocalizationManager.shared.localizedString(for: "purchase_operation_successful") }
    
    // 调试相关
    static var debug_options: String { return LocalizationManager.shared.localizedString(for: "debug_options") }
    static var debug_mode_only: String { return LocalizationManager.shared.localizedString(for: "debug_mode_only") }
    static var debug_set_as_vip: String { return LocalizationManager.shared.localizedString(for: "debug_set_as_vip") }
    static var debug_remove_vip: String { return LocalizationManager.shared.localizedString(for: "debug_remove_vip") }
    static var debug_clear_purchase_records: String { return LocalizationManager.shared.localizedString(for: "debug_clear_purchase_records") }
    static var debug_title: String { return LocalizationManager.shared.localizedString(for: "debug_title") }
    static var debug_vip_set: String { return LocalizationManager.shared.localizedString(for: "debug_vip_set") }
    static var debug_vip_removed: String { return LocalizationManager.shared.localizedString(for: "debug_vip_removed") }
    static var debug_records_cleared: String { return LocalizationManager.shared.localizedString(for: "debug_records_cleared") }
    
    // 识别相关
    static var identify_recognition_failed: String { return LocalizationManager.shared.localizedString(for: "identify_recognition_failed") }
    static var identify_wait_moment: String { return LocalizationManager.shared.localizedString(for: "identify_wait_moment") }
    static var identify_progress_percent: String { return LocalizationManager.shared.localizedString(for: "identify_progress_percent") }
    
    // 相机相关
    static var camera_zoom: String { return LocalizationManager.shared.localizedString(for: "camera_zoom") }
    static var camera_photography_tips: String { return LocalizationManager.shared.localizedString(for: "camera_photography_tips") }
    static var camera_keep_stone_centered: String { return LocalizationManager.shared.localizedString(for: "camera_keep_stone_centered") }
    static var camera_good_image_quality: String { return LocalizationManager.shared.localizedString(for: "camera_good_image_quality") }
    
    
    // 搜索相关
    static var search_enter_keywords: String { return LocalizationManager.shared.localizedString(for: "search_enter_keywords") }
    static var search_no_search: String { return LocalizationManager.shared.localizedString(for: "search_no_search") }
    
    // 个人资料相关
    static var profile_me: String { return LocalizationManager.shared.localizedString(for: "profile_me") }
    static var profile_vip: String { return LocalizationManager.shared.localizedString(for: "profile_vip") }
    static var profile_privileges: String { return LocalizationManager.shared.localizedString(for: "profile_privileges") }
    static var profile_subscribe_now: String { return LocalizationManager.shared.localizedString(for: "profile_subscribe_now") }
    static var profile_my_collection: String { return LocalizationManager.shared.localizedString(for: "profile_my_collection") }
    static var profile_history_record: String { return LocalizationManager.shared.localizedString(for: "profile_history_record") }
    static var profile_no_more_collection: String { return LocalizationManager.shared.localizedString(for: "profile_no_more_collection") }
    
    // 订阅相关
    static var subscription_try_7_days_free: String { return LocalizationManager.shared.localizedString(for: "subscription_try_7_days_free") }
    static var subscription_then_yearly: String { return LocalizationManager.shared.localizedString(for: "subscription_then_yearly") }
    static var subscription_loading_price: String { return LocalizationManager.shared.localizedString(for: "subscription_loading_price") }
    static var subscription_cancel_anytime: String { return LocalizationManager.shared.localizedString(for: "subscription_cancel_anytime") }
    static var subscription_start_free_trial: String { return LocalizationManager.shared.localizedString(for: "subscription_start_free_trial") }
    static var subscription_yearly: String { return LocalizationManager.shared.localizedString(for: "subscription_yearly") }
    static var subscription_monthly: String { return LocalizationManager.shared.localizedString(for: "subscription_monthly") }
    static var subscription_no_commitment: String { return LocalizationManager.shared.localizedString(for: "subscription_no_commitment") }
    static var subscription_payment_charged: String { return LocalizationManager.shared.localizedString(for: "subscription_payment_charged") }
    static var subscription_restore: String { return LocalizationManager.shared.localizedString(for: "subscription_restore") }
    
    // 账户管理相关
    static var account_manage_title: String { return LocalizationManager.shared.localizedString(for: "account_manage_title") }
    static var account_manager_title: String { return LocalizationManager.shared.localizedString(for: "account_manager_title") }
    static var account_manager_language: String { return LocalizationManager.shared.localizedString(for: "account_manager_language") }
    static var account_delete_warning: String { return LocalizationManager.shared.localizedString(for: "account_delete_warning") }
    static var account_delete_information: String { return LocalizationManager.shared.localizedString(for: "account_delete_information") }
    static var account_delete_confirmation: String { return LocalizationManager.shared.localizedString(for: "account_delete_confirmation") }
    
    // 关于页面
    static var about_page_title: String { return LocalizationManager.shared.localizedString(for: "about_page_title") }
    static var about_app_name: String { return LocalizationManager.shared.localizedString(for: "about_app_name") }
    static var about_version: String { return LocalizationManager.shared.localizedString(for: "about_version") }
    static var about_description: String { return LocalizationManager.shared.localizedString(for: "about_description") }
    static var about_email: String { return LocalizationManager.shared.localizedString(for: "about_email") }
    
    // 分享相关
    static var share_image_failed: String { return LocalizationManager.shared.localizedString(for: "share_image_failed") }
    static var share_alert_title: String { return LocalizationManager.shared.localizedString(for: "share_alert_title") }
    static var share_alert_message: String { return LocalizationManager.shared.localizedString(for: "share_alert_message") }
    static var share_title: String { return LocalizationManager.shared.localizedString(for: "share_title") }
    static var share_download: String { return LocalizationManager.shared.localizedString(for: "share_download") }
    static var share_share: String { return LocalizationManager.shared.localizedString(for: "share_share") }
    
    // 鸟类特征相关
    static var stone_basic_information: String { return LocalizationManager.shared.localizedString(for: "stone_basic_information") }
    static var stone_color_features: String { return LocalizationManager.shared.localizedString(for: "stone_color_features") }
    static var stone_habitat: String { return LocalizationManager.shared.localizedString(for: "stone_habitat") }
    static var stone_behavior: String { return LocalizationManager.shared.localizedString(for: "stone_behavior") }
    static var stone_flying: String { return LocalizationManager.shared.localizedString(for: "stone_flying") }
    static var stone_size: String { return LocalizationManager.shared.localizedString(for: "stone_size") }
    static var stone_no_data: String { return LocalizationManager.shared.localizedString(for: "stone_no_data") }
    static var stone_season_info: String { return LocalizationManager.shared.localizedString(for: "stone_season_info") }
    static var stone_visible_months: String { return LocalizationManager.shared.localizedString(for: "stone_visible_months") }
    static var stone_visible_year_round: String { return LocalizationManager.shared.localizedString(for: "stone_visible_year_round") }
    static var stone_plumage: String { return LocalizationManager.shared.localizedString(for: "stone_plumage") }
    
    // 订阅页面特有文本
    static var subscription_app_name: String { return LocalizationManager.shared.localizedString(for: "subscription_app_name") }
    static var subscription_feature_12000_species: String { return LocalizationManager.shared.localizedString(for: "subscription_feature_12000_species") }
    static var subscription_feature_high_accuracy: String { return LocalizationManager.shared.localizedString(for: "subscription_feature_high_accuracy") }
    static var subscription_feature_attract_stones: String { return LocalizationManager.shared.localizedString(for: "subscription_feature_attract_stones") }
    static var subscription_feature_unlimited_id: String { return LocalizationManager.shared.localizedString(for: "subscription_feature_unlimited_id") }
    static var subscription_feature_expand_knowledge: String { return LocalizationManager.shared.localizedString(for: "subscription_feature_expand_knowledge") }
    static var subscription_try_it_free: String { return LocalizationManager.shared.localizedString(for: "subscription_try_it_free") }
    static var subscription_continue: String { return LocalizationManager.shared.localizedString(for: "subscription_continue") }
    static var subscription_7_days_then_yearly: String { return LocalizationManager.shared.localizedString(for: "subscription_7_days_then_yearly") }
    static var subscription_7_days_free_trial_yearly: String { return LocalizationManager.shared.localizedString(for: "subscription_7_days_free_trial_yearly") }
    static var subscription_payment_terms: String { return LocalizationManager.shared.localizedString(for: "subscription_payment_terms") }
    static var subscription_terms_and: String { return LocalizationManager.shared.localizedString(for: "subscription_terms_and") }
    
    // ConvertPage相关
    static var convert_title: String { return LocalizationManager.shared.localizedString(for: "convert_title") }
    static var convert_feature_1: String { return LocalizationManager.shared.localizedString(for: "convert_feature_1") }
    static var convert_feature_2: String { return LocalizationManager.shared.localizedString(for: "convert_feature_2") }
    static var convert_feature_3: String { return LocalizationManager.shared.localizedString(for: "convert_feature_3") }
    static var convert_feature_4: String { return LocalizationManager.shared.localizedString(for: "convert_feature_4") }
    static var convert_feature_5: String { return LocalizationManager.shared.localizedString(for: "convert_feature_5") }
    static var convert_yearly: String { return LocalizationManager.shared.localizedString(for: "convert_yearly") }
    static var convert_monthly: String { return LocalizationManager.shared.localizedString(for: "convert_monthly") }
    static var convert_loading_price: String { return LocalizationManager.shared.localizedString(for: "convert_loading_price") }
    static var convert_free_trial_yearly: String { return LocalizationManager.shared.localizedString(for: "convert_free_trial_yearly") }
    static var convert_free_trial_loading: String { return LocalizationManager.shared.localizedString(for: "convert_free_trial_loading") }
    static var convert_try_free: String { return LocalizationManager.shared.localizedString(for: "convert_try_free") }
    static var convert_continue: String { return LocalizationManager.shared.localizedString(for: "convert_continue") }
    static var convert_cancel_anytime: String { return LocalizationManager.shared.localizedString(for: "convert_cancel_anytime") }
    static var convert_cancel_notice: String { return LocalizationManager.shared.localizedString(for: "convert_cancel_notice") }
    static var convert_payment_terms: String { return LocalizationManager.shared.localizedString(for: "convert_payment_terms") }
    static var convert_terms_of_use: String { return LocalizationManager.shared.localizedString(for: "convert_terms_of_use") }
    static var convert_and: String { return LocalizationManager.shared.localizedString(for: "convert_and") }
    static var convert_privacy_policy: String { return LocalizationManager.shared.localizedString(for: "convert_privacy_policy") }

    
    // 其他页面缺失的本地化key
    static var share_image_load_failed: String { return LocalizationManager.shared.localizedString(for: "share_image_load_failed") }
    static var suggestion_send: String { return LocalizationManager.shared.localizedString(for: "suggestion_send") }
    static var suggestion_required_field: String { return LocalizationManager.shared.localizedString(for: "suggestion_required_field") }
    static var my_collection_no_more: String { return LocalizationManager.shared.localizedString(for: "my_collection_no_more") }
    static var about_email_address: String { return LocalizationManager.shared.localizedString(for: "about_email_address") }
    static var snap_tip_photography_tips: String { return LocalizationManager.shared.localizedString(for: "snap_tip_photography_tips") }
    static var snap_tip_keep_stone_centered: String { return LocalizationManager.shared.localizedString(for: "snap_tip_keep_stone_centered") }
    static var sound_take_to_identify_stones: String { return LocalizationManager.shared.localizedString(for: "sound_take_to_identify_stones") }
    
    // 相机模式选择
    static var camera_mode_by_photo: String { return LocalizationManager.shared.localizedString(for: "camera_mode_by_photo") }
    static var camera_mode_by_sound: String { return LocalizationManager.shared.localizedString(for: "camera_mode_by_sound") }
    
    // 指导页相关
    static var instruction_page_title: String { return LocalizationManager.shared.localizedString(for: "instruction_page_title") }
    static var instruction_good_image_quality: String { return LocalizationManager.shared.localizedString(for: "instruction_good_image_quality") }
    static var instruction_step_1: String { return LocalizationManager.shared.localizedString(for: "instruction_step_1") }
    static var instruction_step_2: String { return LocalizationManager.shared.localizedString(for: "instruction_step_2") }
    static var instruction_step_3: String { return LocalizationManager.shared.localizedString(for: "instruction_step_3") }
    static var instruction_step_4: String { return LocalizationManager.shared.localizedString(for: "instruction_step_4") }
    static var instruction_step_5: String { return LocalizationManager.shared.localizedString(for: "instruction_step_5") }
    static var instruction_identify: String { return LocalizationManager.shared.localizedString(for: "instruction_identify") }
    
    // 更多图片
    static var more_images: String { return LocalizationManager.shared.localizedString(for: "more_images") }
    
    // 拍摄技巧
    static var snap_tip_too_far: String { return LocalizationManager.shared.localizedString(for: "snap_tip_too_far") }
    static var snap_tip_too_close: String { return LocalizationManager.shared.localizedString(for: "snap_tip_too_close") }
    static var snap_tip_blurry: String { return LocalizationManager.shared.localizedString(for: "snap_tip_blurry") }
    static var snap_tip_multiple_species: String { return LocalizationManager.shared.localizedString(for: "snap_tip_multiple_species") }
    
    // Mushroom Features
    static var stone_observation_number: String { return LocalizationManager.shared.localizedString(for: "stone_observation_number") }

    // Share
    static var share_no_content: String { return LocalizationManager.shared.localizedString(for: "share_no_content") }
    static var share_failed: String { return LocalizationManager.shared.localizedString(for: "share_failed") }
    static var share_ok: String { return LocalizationManager.shared.localizedString(for: "share_ok") }
    static var share_stone_not_found: String { return LocalizationManager.shared.localizedString(for: "share_stone_not_found") }

    // Camera
    static var camera_retake: String { return LocalizationManager.shared.localizedString(for: "camera_retake") }
    static var camera_mode_ai_enhancer: String { return LocalizationManager.shared.localizedString(for: "camera_mode_ai_enhancer") }
    
    // Account Manager
    static var account_warning: String { return LocalizationManager.shared.localizedString(for: "account_warning") }
    static var account_cancel: String { return LocalizationManager.shared.localizedString(for: "account_cancel") }
    static var account_delete: String { return LocalizationManager.shared.localizedString(for: "account_delete") }

    // Share
    static var share_error: String { return LocalizationManager.shared.localizedString(for: "share_error") }
    static var share_image_not_available: String { return LocalizationManager.shared.localizedString(for: "share_image_not_available") }
    static var share_success: String { return LocalizationManager.shared.localizedString(for: "share_success") }
    static var share_image_saved: String { return LocalizationManager.shared.localizedString(for: "share_image_saved") }
    static var share_permission_denied: String { return LocalizationManager.shared.localizedString(for: "share_permission_denied") }
    static var share_permission_message: String { return LocalizationManager.shared.localizedString(for: "share_permission_message") }
    static var share_card_saved: String { return LocalizationManager.shared.localizedString(for: "share_card_saved") }
    
    // Share Error
    static var share_error_invalid_url: String { return LocalizationManager.shared.localizedString(for: "share_error_invalid_url") }
    static var share_error_download_failed: String { return LocalizationManager.shared.localizedString(for: "share_error_download_failed") }
    static var share_error_no_content: String { return LocalizationManager.shared.localizedString(for: "share_error_no_content") }

    // Debug
    static var debug_refresh_products: String { return LocalizationManager.shared.localizedString(for: "debug_refresh_products") }

    // Profile
    static var profile_error_load_history: String { return LocalizationManager.shared.localizedString(for: "profile_error_load_history") }
    static var profile_error_load_sound_history: String { return LocalizationManager.shared.localizedString(for: "profile_error_load_sound_history") }
    
    // Debug Messages
    static var debug_price_not_retrieved: String { return LocalizationManager.shared.localizedString(for: "debug_price_not_retrieved") }
    static var debug_load_image_history_failed: String { return LocalizationManager.shared.localizedString(for: "debug_load_image_history_failed") }
    static var debug_load_sound_history_failed: String { return LocalizationManager.shared.localizedString(for: "debug_load_sound_history_failed") }

    // Debug Messages - Convert Page
    static var debug_sandbox_test_info: String { return LocalizationManager.shared.localizedString(for: "debug_sandbox_test_info") }
    static var debug_unknown: String { return LocalizationManager.shared.localizedString(for: "debug_unknown") }
    static var debug_empty_product_list: String { return LocalizationManager.shared.localizedString(for: "debug_empty_product_list") }
    static var debug_product_not_configured: String { return LocalizationManager.shared.localizedString(for: "debug_product_not_configured") }
    static var debug_product_not_ready: String { return LocalizationManager.shared.localizedString(for: "debug_product_not_ready") }
    static var debug_bundle_id_mismatch: String { return LocalizationManager.shared.localizedString(for: "debug_bundle_id_mismatch") }
    static var debug_sandbox_not_logged_in: String { return LocalizationManager.shared.localizedString(for: "debug_sandbox_not_logged_in") }
    static var debug_network_issue: String { return LocalizationManager.shared.localizedString(for: "debug_network_issue") }
    static var debug_manual_request_products: String { return LocalizationManager.shared.localizedString(for: "debug_manual_request_products") }
    static var debug_request_complete: String { return LocalizationManager.shared.localizedString(for: "debug_request_complete") }
    static var debug_manual_refresh_complete: String { return LocalizationManager.shared.localizedString(for: "debug_manual_refresh_complete") }
    static var debug_product_info: String { return LocalizationManager.shared.localizedString(for: "debug_product_info") }
    static var debug_product_price: String { return LocalizationManager.shared.localizedString(for: "debug_product_price") }
    static var debug_product_title: String { return LocalizationManager.shared.localizedString(for: "debug_product_title") }
    static var debug_product_description: String { return LocalizationManager.shared.localizedString(for: "debug_product_description") }

    // MARK: - RetainPage
    static var retain_title: String { return LocalizationManager.shared.localizedString(for: "retain_title") }
    static var retain_restore: String { return LocalizationManager.shared.localizedString(for: "retain_restore") }
    static var retain_timeline_today: String { return LocalizationManager.shared.localizedString(for: "retain_timeline_today") }
    static var retain_timeline_today_desc: String { return LocalizationManager.shared.localizedString(for: "retain_timeline_today_desc") }
    static var retain_timeline_day1_6: String { return LocalizationManager.shared.localizedString(for: "retain_timeline_day1_6") }
    static var retain_timeline_day1_6_desc: String { return LocalizationManager.shared.localizedString(for: "retain_timeline_day1_6_desc") }
    static var retain_timeline_day7: String { return LocalizationManager.shared.localizedString(for: "retain_timeline_day7") }
    static var retain_timeline_day7_desc: String { return LocalizationManager.shared.localizedString(for: "retain_timeline_day7_desc") }
    static var retain_try_free: String { return LocalizationManager.shared.localizedString(for: "retain_try_free") }
    static var retain_then_yearly: String { return LocalizationManager.shared.localizedString(for: "retain_then_yearly") }
    static var retain_loading_price: String { return LocalizationManager.shared.localizedString(for: "retain_loading_price") }
    static var retain_start_trial: String { return LocalizationManager.shared.localizedString(for: "retain_start_trial") }
    static var retain_price_then: String { return LocalizationManager.shared.localizedString(for: "retain_price_then") }
    static var retain_price_year_cancel: String { return LocalizationManager.shared.localizedString(for: "retain_price_year_cancel") }

    // MARK: - Permissions
    static var microphone_permission_title: String { return LocalizationManager.shared.localizedString(for: "microphone_permission_title") }
    static var microphone_permission_desc: String { return LocalizationManager.shared.localizedString(for: "microphone_permission_desc") }
    static var microphone_permission_button: String { return LocalizationManager.shared.localizedString(for: "microphone_permission_button") }

    // MARK: - 缺失的变量补充
    // Home Action Types
    static var home_action_type_valuation: String { return LocalizationManager.shared.localizedString(for: "home_action_type_valuation") }
    static var home_action_type_identify: String { return LocalizationManager.shared.localizedString(for: "home_action_type_identify") }
    static var home_action_type_detector: String { return LocalizationManager.shared.localizedString(for: "home_action_type_detector") }
    
    // FindTreasure Page
    static var find_treasure_title: String { return LocalizationManager.shared.localizedString(for: "find_treasure_title") }
    static var find_treasure_status_normal: String { return LocalizationManager.shared.localizedString(for: "find_treasure_status_normal") }
    static var find_treasure_status_slight: String { return LocalizationManager.shared.localizedString(for: "find_treasure_status_slight") }
    static var find_treasure_status_detected: String { return LocalizationManager.shared.localizedString(for: "find_treasure_status_detected") }
    static var find_treasure_status_strong: String { return LocalizationManager.shared.localizedString(for: "find_treasure_status_strong") }
    
    // Sound
    static var sound_permission_required: String { return LocalizationManager.shared.localizedString(for: "sound_permission_required") }
    static var sound_take_to_identify: String { return LocalizationManager.shared.localizedString(for: "sound_take_to_identify") }
    
    // Profile Page
    static var profile_wishlist: String { return LocalizationManager.shared.localizedString(for: "profile_wishlist") }
    static var profile_refreshing: String { return LocalizationManager.shared.localizedString(for: "profile_refreshing") }
    static var profile_load_more: String { return LocalizationManager.shared.localizedString(for: "profile_load_more") }
    static var profile_load_more_button: String { return LocalizationManager.shared.localizedString(for: "profile_load_more_button") }
    static var profile_no_more_data: String { return LocalizationManager.shared.localizedString(for: "profile_no_more_data") }
    
    // Setting Page
    static var setting_checking_sandbox: String { return LocalizationManager.shared.localizedString(for: "setting_checking_sandbox") }
    static var setting_please_wait: String { return LocalizationManager.shared.localizedString(for: "setting_please_wait") }
    static var setting_sandbox_test_result: String { return LocalizationManager.shared.localizedString(for: "setting_sandbox_test_result") }
    static var setting_test_purchase: String { return LocalizationManager.shared.localizedString(for: "setting_test_purchase") }
    static var setting_restore_purchase: String { return LocalizationManager.shared.localizedString(for: "setting_restore_purchase") }
    static var setting_close: String { return LocalizationManager.shared.localizedString(for: "setting_close") }
    static var setting_select_product: String { return LocalizationManager.shared.localizedString(for: "setting_select_product") }
    static var setting_cannot_purchase: String { return LocalizationManager.shared.localizedString(for: "setting_cannot_purchase") }
    static var setting_load_products_first: String { return LocalizationManager.shared.localizedString(for: "setting_load_products_first") }
    static var setting_confirm: String { return LocalizationManager.shared.localizedString(for: "setting_confirm") }
    static var setting_cancel: String { return LocalizationManager.shared.localizedString(for: "setting_cancel") }
    static var setting_purchasing: String { return LocalizationManager.shared.localizedString(for: "setting_purchasing") }
    static var setting_purchase_success: String { return LocalizationManager.shared.localizedString(for: "setting_purchase_success") }
    static var setting_purchase_failed: String { return LocalizationManager.shared.localizedString(for: "setting_purchase_failed") }
    static var setting_purchase_success_message: String { return LocalizationManager.shared.localizedString(for: "setting_purchase_success_message") }
    static var setting_purchase_failed_message: String { return LocalizationManager.shared.localizedString(for: "setting_purchase_failed_message") }
    static var setting_purchase_error: String { return LocalizationManager.shared.localizedString(for: "setting_purchase_error") }
    static var setting_error_message: String { return LocalizationManager.shared.localizedString(for: "setting_error_message") }
    static var setting_restoring_purchase: String { return LocalizationManager.shared.localizedString(for: "setting_restoring_purchase") }
    static var setting_restore_complete: String { return LocalizationManager.shared.localizedString(for: "setting_restore_complete") }
    static var setting_vip_status: String { return LocalizationManager.shared.localizedString(for: "setting_vip_status") }
    static var setting_vip_activated: String { return LocalizationManager.shared.localizedString(for: "setting_vip_activated") }
    static var setting_vip_not_activated: String { return LocalizationManager.shared.localizedString(for: "setting_vip_not_activated") }
    static var setting_restore_failed: String { return LocalizationManager.shared.localizedString(for: "setting_restore_failed") }
    
    // Suggestion Page
    static var suggestion_email_subject: String { return LocalizationManager.shared.localizedString(for: "suggestion_email_subject") }
    static var suggestion_cant_send_email: String { return LocalizationManager.shared.localizedString(for: "suggestion_cant_send_email") }
    static var suggestion_email_setup_message: String { return LocalizationManager.shared.localizedString(for: "suggestion_email_setup_message") }
    static var suggestion_confirm: String { return LocalizationManager.shared.localizedString(for: "suggestion_confirm") }
    
    // Camera Page
    static var camera_go_button: String { return LocalizationManager.shared.localizedString(for: "camera_go_button") }
    
    // Recognize Page
    static var recognize_auto_saved_collection: String { return LocalizationManager.shared.localizedString(for: "recognize_auto_saved_collection") }
    static var recognize_stone_loading: String { return LocalizationManager.shared.localizedString(for: "recognize_stone_loading") }
    static var recognize_invalid_id: String { return LocalizationManager.shared.localizedString(for: "recognize_invalid_id") }
    static var recognize_added_collection_success: String { return LocalizationManager.shared.localizedString(for: "recognize_added_collection_success") }
    static var recognize_added_collection_failed: String { return LocalizationManager.shared.localizedString(for: "recognize_added_collection_failed") }
    static var recognize_stone_loading_wait: String { return LocalizationManager.shared.localizedString(for: "recognize_stone_loading_wait") }
    static var recognize_added_wishlist_success: String { return LocalizationManager.shared.localizedString(for: "recognize_added_wishlist_success") }
    static var recognize_added_wishlist_failed: String { return LocalizationManager.shared.localizedString(for: "recognize_added_wishlist_failed") }
    static var recognize_delete_wishlist_success: String { return LocalizationManager.shared.localizedString(for: "recognize_delete_wishlist_success") }
    static var recognize_delete_wishlist_failed: String { return LocalizationManager.shared.localizedString(for: "recognize_delete_wishlist_failed") }
    static var change_result_failed: String { return LocalizationManager.shared.localizedString(for: "change_result_failed")}
    
    // Detail Page
    static var detail_page_title: String { return LocalizationManager.shared.localizedString(for: "detail_page_title") }
    static var detail_stone_loading: String { return LocalizationManager.shared.localizedString(for: "detail_stone_loading") }
    static var detail_collected: String { return LocalizationManager.shared.localizedString(for: "detail_collected") }
    static var detail_collected_failed: String { return LocalizationManager.shared.localizedString(for: "detail_collected_failed") }
    static var detail_collected_error: String { return LocalizationManager.shared.localizedString(for: "detail_collected_error") }
    static var detail_stone_loading_wait: String { return LocalizationManager.shared.localizedString(for: "detail_stone_loading_wait") }
    static var detail_added_wishlist_success: String { return LocalizationManager.shared.localizedString(for: "detail_added_wishlist_success") }
    static var detail_added_wishlist_failed: String { return LocalizationManager.shared.localizedString(for: "detail_added_wishlist_failed") }
    static var detail_add_wish: String { return LocalizationManager.shared.localizedString(for: "detail_add_wish") }
    static var detail_del_wish: String { return LocalizationManager.shared.localizedString(for: "detail_del_wish") }
    
    // Mushroom Info Section
    static var stone_usage: String { return LocalizationManager.shared.localizedString(for: "stone_usage") }
    static var stone_health_risks: String { return LocalizationManager.shared.localizedString(for: "stone_health_risks") }
    static var stone_original_vs_fake: String { return LocalizationManager.shared.localizedString(for: "stone_original_vs_fake") }
    static var stone_storage: String { return LocalizationManager.shared.localizedString(for: "stone_storage") }
    static var stone_cleaning_tips: String { return LocalizationManager.shared.localizedString(for: "stone_cleaning_tips") }
    static var stone_chemical_formula: String { return LocalizationManager.shared.localizedString(for: "stone_chemical_formula") }
    static var stone_chemical_classification: String { return LocalizationManager.shared.localizedString(for: "stone_chemical_classification") }
    static var stone_crystal_system: String { return LocalizationManager.shared.localizedString(for: "stone_crystal_system") }
    static var stone_hardness: String { return LocalizationManager.shared.localizedString(for: "stone_hardness") }
    static var stone_density: String { return LocalizationManager.shared.localizedString(for: "stone_density") }
    static var stone_chemical_elements: String { return LocalizationManager.shared.localizedString(for: "stone_chemical_elements") }
    static var stone_estimated_value: String { return LocalizationManager.shared.localizedString(for: "stone_estimated_value") }
    static var add_to_collection: String { return LocalizationManager.shared.localizedString(for: "add_to_collection") }
    static var possible_price_range: String { return LocalizationManager.shared.localizedString(for: "possible_price_range")}
    static var note: String { return LocalizationManager.shared.localizedString(for: "note")}
    
    // Purchase Testing
    static var purchase_testing_sandbox_pricing: String { return LocalizationManager.shared.localizedString(for: "purchase_testing_sandbox_pricing") }
    static var purchase_sandbox_test_results: String { return LocalizationManager.shared.localizedString(for: "purchase_sandbox_test_results") }
    static var purchase_error_info: String { return LocalizationManager.shared.localizedString(for: "purchase_error_info") }
    static var purchase_loading_status: String { return LocalizationManager.shared.localizedString(for: "purchase_loading_status") }
    static var purchase_no_products_error: String { return LocalizationManager.shared.localizedString(for: "purchase_no_products_error") }
    static var purchase_products_found: String { return LocalizationManager.shared.localizedString(for: "purchase_products_found") }
    static var purchase_product_name: String { return LocalizationManager.shared.localizedString(for: "purchase_product_name") }
    static var purchase_product_id: String { return LocalizationManager.shared.localizedString(for: "purchase_product_id") }
    static var purchase_product_price: String { return LocalizationManager.shared.localizedString(for: "purchase_product_price") }
    static var purchase_product_type: String { return LocalizationManager.shared.localizedString(for: "purchase_product_type") }
    static var purchase_subscription_period: String { return LocalizationManager.shared.localizedString(for: "purchase_subscription_period") }
    static var purchase_trial_offer: String { return LocalizationManager.shared.localizedString(for: "purchase_trial_offer") }
    static var purchase_system_info: String { return LocalizationManager.shared.localizedString(for: "purchase_system_info") }
    static var purchase_bundle_id: String { return LocalizationManager.shared.localizedString(for: "purchase_bundle_id") }
    static var purchase_vip_status: String { return LocalizationManager.shared.localizedString(for: "purchase_vip_status") }
    static var purchase_vip_yes: String { return LocalizationManager.shared.localizedString(for: "purchase_vip_yes") }
    static var purchase_vip_no: String { return LocalizationManager.shared.localizedString(for: "purchase_vip_no") }
    static var purchase_retest: String { return LocalizationManager.shared.localizedString(for: "purchase_retest") }
    static var purchase_test_purchase: String { return LocalizationManager.shared.localizedString(for: "purchase_test_purchase") }
    static var purchase_close: String { return LocalizationManager.shared.localizedString(for: "purchase_close") }
    static var purchase_cannot_purchase: String { return LocalizationManager.shared.localizedString(for: "purchase_cannot_purchase") }
    static var purchase_load_products_first: String { return LocalizationManager.shared.localizedString(for: "purchase_load_products_first") }
    static var purchase_select_product_to_buy: String { return LocalizationManager.shared.localizedString(for: "purchase_select_product_to_buy") }
    static var purchase_purchasing: String { return LocalizationManager.shared.localizedString(for: "purchase_purchasing") }
    static var purchase_purchase_success: String { return LocalizationManager.shared.localizedString(for: "purchase_purchase_success") }
    static var purchase_purchase_failed: String { return LocalizationManager.shared.localizedString(for: "purchase_purchase_failed") }
    static var purchase_congratulations: String { return LocalizationManager.shared.localizedString(for: "purchase_congratulations") }
    static var purchase_not_completed: String { return LocalizationManager.shared.localizedString(for: "purchase_not_completed") }
    static var purchase_purchase_error: String { return LocalizationManager.shared.localizedString(for: "purchase_purchase_error") }
    static var purchase_error_message: String { return LocalizationManager.shared.localizedString(for: "purchase_error_message") }
    static var purchase_restoring_purchases: String { return LocalizationManager.shared.localizedString(for: "purchase_restoring_purchases") }
    static var purchase_restore_complete: String { return LocalizationManager.shared.localizedString(for: "purchase_restore_complete") }
    static var purchase_vip_activated: String { return LocalizationManager.shared.localizedString(for: "purchase_vip_activated") }
    static var purchase_vip_not_activated: String { return LocalizationManager.shared.localizedString(for: "purchase_vip_not_activated") }
    static var purchase_restore_failed: String { return LocalizationManager.shared.localizedString(for: "purchase_restore_failed") }
    static var purchase_auto_renewable: String { return LocalizationManager.shared.localizedString(for: "purchase_auto_renewable") }
    static var purchase_non_renewable: String { return LocalizationManager.shared.localizedString(for: "purchase_non_renewable") }
    static var purchase_consumable: String { return LocalizationManager.shared.localizedString(for: "purchase_consumable") }
    static var purchase_non_consumable: String { return LocalizationManager.shared.localizedString(for: "purchase_non_consumable") }
    static var purchase_unknown_type: String { return LocalizationManager.shared.localizedString(for: "purchase_unknown_type") }
    static var purchase_day: String { return LocalizationManager.shared.localizedString(for: "purchase_day") }
    static var purchase_week: String { return LocalizationManager.shared.localizedString(for: "purchase_week") }
    static var purchase_month: String { return LocalizationManager.shared.localizedString(for: "purchase_month") }
    static var purchase_year: String { return LocalizationManager.shared.localizedString(for: "purchase_year") }
    static var purchase_unknown: String { return LocalizationManager.shared.localizedString(for: "purchase_unknown") }
    
    // MARK: - Mushroom Detail Components
    static var stone_chemical_properties: String { return LocalizationManager.shared.localizedString(for: "stone_chemical_properties") }
    static var stone_impurities: String { return LocalizationManager.shared.localizedString(for: "stone_impurities") }
    static var stone_variety: String { return LocalizationManager.shared.localizedString(for: "stone_variety") }
    static var stone_physical_properties: String { return LocalizationManager.shared.localizedString(for: "stone_physical_properties") }
    static var stone_colors: String { return LocalizationManager.shared.localizedString(for: "stone_colors") }
    static var stone_luster: String { return LocalizationManager.shared.localizedString(for: "stone_luster") }
    static var stone_diaphaneity: String { return LocalizationManager.shared.localizedString(for: "stone_diaphaneity") }
    static var stone_magnetism: String { return LocalizationManager.shared.localizedString(for: "stone_magnetism") }
    static var stone_streak: String { return LocalizationManager.shared.localizedString(for: "stone_streak") }
    static var stone_tenacity: String { return LocalizationManager.shared.localizedString(for: "stone_tenacity") }
    static var stone_cleavage: String { return LocalizationManager.shared.localizedString(for: "stone_cleavage") }
    static var stone_fracture: String { return LocalizationManager.shared.localizedString(for: "stone_fracture") }
    static var stone_durability_rating: String { return LocalizationManager.shared.localizedString(for: "stone_durability_rating") }
    static var stone_scratch_resistance: String { return LocalizationManager.shared.localizedString(for: "stone_scratch_resistance") }
    static var stone_toughness: String { return LocalizationManager.shared.localizedString(for: "stone_toughness") }
    static var stone_stability: String { return LocalizationManager.shared.localizedString(for: "stone_stability") }
    static var stone_care_instructions: String { return LocalizationManager.shared.localizedString(for: "stone_care_instructions") }
    static var stone_light: String { return LocalizationManager.shared.localizedString(for: "stone_light") }
    static var stone_temperature: String { return LocalizationManager.shared.localizedString(for: "stone_temperature") }
    static var stone_price_information: String { return LocalizationManager.shared.localizedString(for: "stone_price_information") }
    static var stone_per_carat: String { return LocalizationManager.shared.localizedString(for: "stone_per_carat") }
    static var stone_per_pound: String { return LocalizationManager.shared.localizedString(for: "stone_per_pound") }
    static var stone_metaphysical_properties: String { return LocalizationManager.shared.localizedString(for: "stone_metaphysical_properties") }
    static var stone_chakra_root: String { return LocalizationManager.shared.localizedString(for: "stone_chakra_root") }
    static var stone_chakra_sacral: String { return LocalizationManager.shared.localizedString(for: "stone_chakra_sacral") }
    static var stone_chakra_solar: String { return LocalizationManager.shared.localizedString(for: "stone_chakra_solar") }
    static var stone_chakra_heart: String { return LocalizationManager.shared.localizedString(for: "stone_chakra_heart") }
    static var stone_chakra_throat: String { return LocalizationManager.shared.localizedString(for: "stone_chakra_throat") }
    static var stone_chakra_third_eye: String { return LocalizationManager.shared.localizedString(for: "stone_chakra_third_eye") }
    static var stone_chakra_crown: String { return LocalizationManager.shared.localizedString(for: "stone_chakra_crown") }
    static var stone_quality_tranquillity: String { return LocalizationManager.shared.localizedString(for: "stone_quality_tranquillity") }
    static var stone_quality_grounding: String { return LocalizationManager.shared.localizedString(for: "stone_quality_grounding") }
    static var stone_quality_protection: String { return LocalizationManager.shared.localizedString(for: "stone_quality_protection") }
    static var stone_quality_healing: String { return LocalizationManager.shared.localizedString(for: "stone_quality_healing") }
    static var stone_quality_clarity: String { return LocalizationManager.shared.localizedString(for: "stone_quality_clarity") }
    static var stone_quality_spiritual: String { return LocalizationManager.shared.localizedString(for: "stone_quality_spiritual") }
    static var stone_quality_energy: String { return LocalizationManager.shared.localizedString(for: "stone_quality_energy") }
    static var stone_quality_prosperity: String { return LocalizationManager.shared.localizedString(for: "stone_quality_prosperity") }
    static var stone_quality_balance: String { return LocalizationManager.shared.localizedString(for: "stone_quality_balance") }
    static var stone_quality_love: String { return LocalizationManager.shared.localizedString(for: "stone_quality_love") }
    static var stone_enhancing: String { return LocalizationManager.shared.localizedString(for: "stone_enhancing") }
    static var stone_charging: String { return LocalizationManager.shared.localizedString(for: "stone_charging") }
    static var stone_cleansing: String { return LocalizationManager.shared.localizedString(for: "stone_cleansing") }
    
    static var profile_error_load_more_data: String { return LocalizationManager.shared.localizedString(for: "profile_error_load_more_data") }
    static var profile_error_load_wishlist: String { return LocalizationManager.shared.localizedString(for: "profile_error_load_wishlist") }
    static var profile_error_load_more_wishlist: String { return LocalizationManager.shared.localizedString(for: "profile_error_load_more_wishlist") }

    // MARK: - Valuation
    static var valuation_in_progress: String { return LocalizationManager.shared.localizedString(for: "valuation_in_progress") }
    static var valuation_step_identification: String { return LocalizationManager.shared.localizedString(for: "valuation_step_identification") }
    static var valuation_step_quality_evaluation: String { return LocalizationManager.shared.localizedString(for: "valuation_step_quality_evaluation") }
    static var valuation_step_market_price_search: String { return LocalizationManager.shared.localizedString(for: "valuation_step_market_price_search") }
    static var valuation_not_found: String { return LocalizationManager.shared.localizedString(for: "valuation_not_found") }
    static var are_you_satisfied_with_the_result: String { return LocalizationManager.shared.localizedString(for: "are_you_satisfied_with_the_result") }
    static var thanks_for_your_feedback: String { return LocalizationManager.shared.localizedString(for: "thanks_for_your_feedback") }
    static var valuation_camera_tips: String { return LocalizationManager.shared.localizedString(for: "valuation_camera_tips")}
    static var metal_detector_tips_content: String { return LocalizationManager.shared.localizedString(for: "metal_detector_tips_content")}
}
