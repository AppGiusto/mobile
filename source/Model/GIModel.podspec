Pod::Spec.new do |s|
    s.name         = 'GIModel'
    s.version      = '1.0.0'
    s.summary      = 'A library that retrieves the current price of your favorite ice cream.'
    s.author       = { 'Eloy Durán' => 'eloy.de.enige@gmail.com' }
    s.source       = { :git => 'https://github.com/alloy/ice-pop.git', :tag => '0.4.2' }
    
    s.source_files = 'Classes/*.{h,m}'
    s.prefix_header_contents = '#import "Underscore.h"',
    '#ifndef _',
    '#define _ Underscore',
    '#endif',
    '#import "DateTools.h"',
    '#import "NSDate+MTDates.h"',
    '#import "MyiOSHelpers.h"',
    '#import "CoreData+MagicalRecord.h"',
    '#import <Parse/Parse.h>',
    '#import "ParseModel.h"',
    '#import <CoreData/CoreData.h>',
    '#import "GIModelDefines.h"'
    
    s.xcconfig = { "FRAMEWORK_SEARCH_PATHS" => '"$(PODS_ROOT)/Parse"' }
    
    s.dependency  'MyiOSHelpers', '~> 1.0.0'
    s.dependency  'Underscore.m', '~> 0.2.0'
    s.dependency  'Parse', '~> 1.3.0'
    s.dependency  'ParseModel'
    s.dependency  'DateTools', '~> 1.4.3'
    s.dependency  'MTDates', '~> 0.13.0'
    # s.dependency  'PFIncrementalStore', '~> 0.2'
    # s.dependency  'Parse+PromiseKit', '~> 0.9'
    # s.dependency  'Parse-SDK-Helpers', '~> 1.1'
    
    
    s.resources = ['GIModel.podspec']
    
    #s.framework = 'CoreData'
    s.weak_framework = 'Parse'
    
    s.subspec "ModelObjects" do |model|
        model.source_files = "Classes/ModelObjects/*.{h,m}"
        
        model.subspec "Relations" do |relations|
            relations.source_files = "Classes/ModelObjects/Relations/*.{h,m}"
        end
        
        model.subspec "Base" do |base|
            base.source_files = "Classes/ModelObjects/Base/*.{h,m}"
        end
    end
    
    s.subspec "ModelStores" do |stores|
        stores.source_files = "Classes/ModelStores/*.{h,m}"
        
        stores.subspec "Base" do |base|
            base.source_files = "Classes/ModelStores/Base/*.{h,m}"
        end
    end
    
    s.subspec "ModelLogic" do |logic|
        logic.source_files = "Classes/ModelLogic/*.{h,m}"
    end
    
    s.subspec "Util" do |util|
        util.source_files = "Classes/Util/*.{h,m}"
    end
    
end
