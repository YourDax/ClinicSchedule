using System;
using System.Collections.Generic;
using System.Net.Http.Json;
using System.Runtime.Intrinsics.Arm;
using System.Text.Json.Serialization;
using System.Text;
using ClinicScheduleBusinessLogic.BusinessLogic;
using ClinicScheduleContracts.BindingModels;
using ClinicScheduleContracts.BusinesLogicContracts;
using ClinicScheduleContracts.BusinessLogicContracts;
using ClinicScheduleContracts.SearchModels;
using ClinicScheduleContracts.StorageContracts;
using ClinicScheduleContracts.ViewModels;
using ClinicScheduleDatabaseImplement.Implements;
using ClinicScheduleModels.Enums;
using ClinicScheduleModels.Models;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Logging;
using Newtonsoft.Json;

namespace ClinicScheduleConsoleApp
{
    class Program
    {
        private static readonly HttpClient client = new HttpClient
        {
            BaseAddress = new Uri("http://localhost:5167/api/Main/")
        };
        /*static void Main(string[] args)
        {         
            var services = new ServiceCollection();
            services.AddLogging(config => config.AddConsole());
            services.AddScoped<IDoctorLogic, DoctorLogic>();
            services.AddScoped<INurseLogic, NurseLogic>();
            services.AddScoped<IDepartmentLogic, DepartmentLogic>();
            services.AddScoped<IShiftLogic, ShiftLogic>();
            services.AddScoped<IScheduleLogic, ScheduleLogic>();

            services.AddScoped<IDoctorStorage, DoctorStorage>();
            services.AddScoped<INurseStorage, NurseStorage>();
            services.AddScoped<IDepartmentStorage, DepartmentStorage>();
            services.AddScoped<IShiftStorage, ShiftStorage>();
            services.AddScoped<IScheduleStorage, ScheduleStorage>();


            var serviceProvider = services.BuildServiceProvider();

            var logger = serviceProvider.GetRequiredService<ILogger<Program>>();
            // Хранилища
            
            

            var doctorLogic = serviceProvider.GetRequiredService<IDoctorLogic>();
            var nurseLogic = serviceProvider.GetRequiredService<INurseLogic>();
            var departmentLogic = serviceProvider.GetRequiredService<IDepartmentLogic>();
            var shiftLogic = serviceProvider.GetRequiredService<IShiftLogic>();
            var scheduleLogic = serviceProvider.GetRequiredService<IScheduleLogic>();

            // Создаем 10 департаментов
            for (int i = 1; i <= 10; i++)
            {
                var depName = $"Департамент #{i}";
                if (departmentLogic.ReadList(new() { name = depName })?.Count == 0)
                {
                    departmentLogic.Create(new DepartmentBindingModel { name = depName });
                    Console.WriteLine($"Создан департамент: {depName}");
                }
                else
                {
                    Console.WriteLine($"Департамент {depName} уже существует");
                }
            }

            var departments = departmentLogic.ReadList(null);
            *//*var doctorLogin = $"doc10_1";
            if (doctorLogic.ReadList(new() { login = doctorLogin })?.Count == 0)
            {
                var doctorFullName = $"Доктор деп #10";
                doctorLogic.Create(new DoctorBindingModel
                {
                    fullname = doctorFullName,
                    login = doctorLogin,
                    password = "pass",
                    birthdate = new DateTime(1980, 1, 1),
                    phoneNumber = "1234567890",
                    specialization = "Терапия",
                    experienceYears = 5,
                    departmentId = 10
                });
                Console.WriteLine($"Создан доктор: {doctorFullName}");
            }*//*

            // Создаем 10 докторов и 10 медсестер для каждого департамента
            foreach (var dep in departments!)
            {
                for (int i = 1; i <= 10; i++)
                {
                    var doctorFullName = $"Доктор {dep.name} #{i}";
                    if (doctorLogic.ReadList(new() { fullname = doctorFullName })?.Count == 0)
                    {
                        var doctorLogin = $"doc{dep.id}_{i}";
                        doctorLogic.Create(new DoctorBindingModel
                        {
                            fullname = doctorFullName,
                            login = doctorLogin,
                            password = "pass",
                            birthdate = new DateTime(1980 + i, 1, 1),
                            phoneNumber = "1234567890",
                            specialization = "Терапия",
                            experienceYears = 5 + i,
                            departmentId = dep.id
                        });
                        Console.WriteLine($"Создан доктор: {doctorFullName}");
                    }
                    else
                    {
                        Console.WriteLine($"Доктор с именем {doctorFullName} уже существует");
                    }

                    var nurseFullName = $"Медсестра {dep.name} #{i}";
                    if (nurseLogic.ReadList(new() { fullname = nurseFullName })?.Count == 0)
                    {
                        var nurseLogin = $"nurse{dep.id}_{i}";
                        nurseLogic.Create(new NurseBindingModel
                        {
                            fullname = nurseFullName,
                            login = nurseLogin,
                            password = "pass",
                            birthdate = new DateTime(1990 + i, 1, 1),
                            phoneNumber = "0987654321",
                            specialization = "Общая практика",
                            experienceYears = 3 + i,
                            departmentId = dep.id
                        });
                        Console.WriteLine($"Создана медсестра: {nurseFullName}");
                    }
                    else
                    {
                        Console.WriteLine($"Медсестра с именем {nurseFullName} уже существует");
                    }
                }
            }



            // Создаем 2 смены для каждого департамента (8:00-16:00 и 16:00-24:00)
            foreach (var dep in departments)
            {
                var today = DateTime.Today;

                var shift1Start = today.AddHours(8);
                var shift1End = today.AddHours(16);

                if (shiftLogic.ReadList(new() { departmentId = dep.id })?.FindAll(s => s.startTime == shift1Start && s.endTime == shift1End).Count == 0)
                {
                    shiftLogic.Create(new ShiftBindingModel
                    {
                        startTime = shift1Start,
                        endTime = shift1End,
                        requiredDoctors = 2,
                        requiredNurses = 1,
                        departmentId = dep.id
                    });
                    Console.WriteLine($"Создана смена 08:00-16:00 для {dep.name}");
                }
                else
                {
                    Console.WriteLine($"Смена 08:00-16:00 для {dep.name} уже существует");
                }

                var shift2Start = today.AddHours(16);
                var shift2End = today.AddHours(24);

                if (shiftLogic.ReadList(new() { departmentId = dep.id })?.FindAll(s => s.startTime == shift2Start && s.endTime == shift2End).Count == 0)
                {
                    shiftLogic.Create(new ShiftBindingModel
                    {
                        startTime = shift2Start,
                        endTime = shift2End,
                        requiredDoctors = 2,
                        requiredNurses = 1,
                        departmentId = dep.id
                    });
                    Console.WriteLine($"Создана смена 16:00-24:00 для {dep.name}");
                }
                else
                {
                    Console.WriteLine($"Смена 16:00-24:00 для {dep.name} уже существует");
                }
            }

            // Ручное создание расписания для первого департамента на сегодня
            var firstDep = departments[0];
            var scheduleDate = DateTime.Today;

            // Получаем смены для департамента — важно, чтобы в model.shifts был непустой список
            var shiftsForFirstDep = shiftLogic.ReadList(new() { departmentId = firstDep.id })!;

            var manualSchedule = new ScheduleBindingModel
            {
                date = scheduleDate,
                departmentId = firstDep.id,
                shifts = shiftsForFirstDep.Cast<IShiftModel>().ToList(),
                assignments = new List<ScheduleAssignmentBindingModel>()
            };


            var createdSchedule = scheduleLogic.Create(manualSchedule);

            Console.WriteLine(createdSchedule
                ? $"Ручное расписание для {firstDep.name} на {scheduleDate:dd.MM.yyyy} создано"
                : "Ошибка создания расписания");


            // Автоматическое создание расписаний для второго департамента на следующие 3 дня
            var secondDep = departments[1];
            var autoScheduleDates = new List<DateTime>
            {
                DateTime.Today.AddDays(1),
                DateTime.Today.AddDays(2),
                DateTime.Today.AddDays(3)
            };

            var generated = scheduleLogic.GenerateSchedule(secondDep.id, autoScheduleDates);
            Console.WriteLine(generated ? $"Автоматическое расписание для {secondDep.name} создано на даты {string.Join(", ", autoScheduleDates)}" : "Ошибка генерации расписания");
            if (generated)
            {
                var schedules = scheduleLogic.ReadList(new() { departmentId = secondDep.id })
                                 ?.Where(s => autoScheduleDates.Contains(s.date.Date))
                                 .ToList();

                if (schedules != null && schedules.Count > 0)
                {
                    Console.WriteLine($"Расписания для {secondDep.name}:");

                    var doctorStorage = serviceProvider.GetRequiredService<IDoctorStorage>();
                    var nurseStorage = serviceProvider.GetRequiredService<INurseStorage>();
                    var shiftStorage = serviceProvider.GetRequiredService<IShiftStorage>();

                    foreach (var schedule in schedules)
                    {
                        Console.WriteLine($"\nРасписание на {schedule.date:dd.MM.yyyy} для департамента {secondDep.name}");

                        var assignments = schedule.assignments;

                        if (assignments == null || assignments.Count == 0)
                        {
                            Console.WriteLine("  Назначений нет");
                            continue;
                        }

                        // Группируем по shiftId
                        var groupedByShift = assignments
                            .GroupBy(a => a.shiftId)
                            .ToList();

                        foreach (var group in groupedByShift)
                        {
                            var shift = shiftStorage.GetElement(new ShiftSearchModel { id = group.Key });

                            if (shift == null)
                            {
                                Console.WriteLine($"  Не найдена смена с id {group.Key}");
                                continue;
                            }

                            Console.WriteLine($"  Смена: {shift.startTime:HH:mm} - {shift.endTime:HH:mm} (Врачей: {shift.requiredDoctors}, Медсестер: {shift.requiredNurses})");

                            foreach (var assignment in group)
                            {
                                string staffName = "Неизвестен";

                                if (assignment.role == Roles.Doctor)
                                {
                                    var doctor = doctorStorage.GetElement(new DoctorSearchModel { id = assignment.staffId });
                                    if (doctor != null) staffName = doctor.fullname;
                                }
                                else if (assignment.role == Roles.Nurse)
                                {
                                    var nurse = nurseStorage.GetElement(new NurseSearchModel { id = assignment.staffId });
                                    if (nurse != null) staffName = nurse.fullname;
                                }

                                var roleStr = assignment.role == Roles.Doctor ? "Врач" : "Медсестра";

                                Console.WriteLine($"    {roleStr}: {staffName}");
                            }
                        }
                    }
                }
                else
                {
                    Console.WriteLine("Расписания не найдены.");
                }
            }



            Console.WriteLine("Тестирование завершено.");

        }*/
        static async Task Main(string[] args)
        {
            Console.WriteLine("=== Тест REST API ===");

            // === Создание департаментов ===
            for (int i = 1; i <= 10; i++)
            {
                string name = $"Департамент #{i}";

                // GET-запрос на получение всех департаментов (или с фильтром, если он работает строго)
                var depListResponse = await client.GetAsync("GetDepartmentList");
                if (!depListResponse.IsSuccessStatusCode)
                {
                    var errorContent = await depListResponse.Content.ReadAsStringAsync();
                    Console.WriteLine($"Ошибка HTTP {depListResponse.StatusCode} при запросе департаментов: {errorContent}");
                    return;
                }

                var deps = await depListResponse.Content.ReadFromJsonAsync<List<DepartmentViewModel>>();

                // Строчная проверка наличия департамента по имени
                var exists = deps?.Any(d => d.name == name) == true;

                if (!exists)
                {
                    var createDepResponse = await client.PostAsJsonAsync("CreateDepartment", new DepartmentBindingModel { name = name });
                    if (createDepResponse.IsSuccessStatusCode)
                        Console.WriteLine($"✅ Создан департамент: {name}");
                    else
                    {
                        var err = await createDepResponse.Content.ReadAsStringAsync();
                        Console.WriteLine($"❌ Ошибка при создании департамента {name}: {err}");
                    }
                }
                else
                {
                    Console.WriteLine($"ℹ️ Департамент {name} уже существует");
                }
            }


            Console.WriteLine("Все департаменты обработаны.");

            // === Получение всех департаментов ===
            var departmentsResponse = await client.GetAsync("GetDepartmentList");
            if (!departmentsResponse.IsSuccessStatusCode)
            {
                var err = await departmentsResponse.Content.ReadAsStringAsync();
                Console.WriteLine($"Ошибка HTTP {departmentsResponse.StatusCode} при получении списка департаментов: {err}");
                return;
            }

            var departments = await departmentsResponse.Content.ReadFromJsonAsync<List<DepartmentViewModel>>();
            Console.WriteLine($"Получено департаментов: {departments?.Count ?? 0}");

            // === Создание докторов и медсестёр ===
            foreach (var dep in departments!)
            {
                for (int i = 1; i <= 10; i++)
                {
                    var doctorName = $"Доктор {dep.name} #{i}";
                    var nurseName = $"Медсестра {dep.name} #{i}";

                    // === Проверка доктора ===
                    var doctorUrl = $"GetDoctorList?fullname={Uri.EscapeDataString(doctorName)}";
                    var doctorResponse = await client.GetAsync(doctorUrl);
                    if (!doctorResponse.IsSuccessStatusCode)
                    {
                        Console.WriteLine($"Ошибка при запросе доктора {doctorName}: {await doctorResponse.Content.ReadAsStringAsync()}");
                        continue;
                    }

                    var existingDoctors = await doctorResponse.Content.ReadFromJsonAsync<List<DoctorViewModel>>();
                    var doctorExists = existingDoctors?.Any(d => d.fullname == doctorName && d.departmentId == dep.id) == true;

                    if (!doctorExists)
                    {
                        var createDoctor = new DoctorBindingModel
                        {
                            fullname = doctorName,
                            login = $"doc{dep.id}_{i}",
                            password = "pass",
                            birthdate = new DateTime(1980 + i, 1, 1),
                            phoneNumber = $"90000000{dep.id:D2}{i:D2}", // уникальный номер
                            experienceYears = 5 + i,
                            departmentId = dep.id
                        };

                        var createDoctorResponse = await client.PostAsJsonAsync("CreateDoctor", createDoctor);
                        if (createDoctorResponse.IsSuccessStatusCode)
                            Console.WriteLine($"✅ Создан доктор: {doctorName}");
                        else
                            Console.WriteLine($"❌ Ошибка при создании доктора {doctorName}: {await createDoctorResponse.Content.ReadAsStringAsync()}");
                    }
                    else
                    {
                        Console.WriteLine($"ℹ️ Доктор {doctorName} уже существует");
                    }

                    // === Проверка медсестры ===
                    var nurseUrl = $"GetNurseList?fullname={Uri.EscapeDataString(nurseName)}";
                    var nurseResponse = await client.GetAsync(nurseUrl);
                    if (!nurseResponse.IsSuccessStatusCode)
                    {
                        Console.WriteLine($"Ошибка при запросе медсестры {nurseName}: {await nurseResponse.Content.ReadAsStringAsync()}");
                        continue;
                    }

                    var existingNurses = await nurseResponse.Content.ReadFromJsonAsync<List<NurseViewModel>>();
                    var nurseExists = existingNurses?.Any(n => n.fullname == nurseName && n.departmentId == dep.id) == true;

                    if (!nurseExists)
                    {
                        var createNurse = new NurseBindingModel
                        {
                            fullname = nurseName,
                            login = $"nurse{dep.id}_{i}",
                            password = "pass",
                            birthdate = new DateTime(1990 + i, 1, 1),
                            phoneNumber = $"91000000{dep.id:D2}{i:D2}", // уникальный номер
                            specialization = "Общая практика",
                            departmentId = dep.id
                        };

                        var createNurseResponse = await client.PostAsJsonAsync("CreateNurse", createNurse);
                        if (createNurseResponse.IsSuccessStatusCode)
                            Console.WriteLine($"✅ Создана медсестра: {nurseName}");
                        else
                            Console.WriteLine($"❌ Ошибка при создании медсестры {nurseName}: {await createNurseResponse.Content.ReadAsStringAsync()}");
                    }
                    else
                    {
                        Console.WriteLine($"ℹ️ Медсестра {nurseName} уже существует");
                    }
                }
            }


            Console.WriteLine("Все доктора и медсестры обработаны.");

            // === Создание смен ===
            foreach (var dep in departments)
            {
                var today = DateTime.Today;
                var shift1 = new ShiftBindingModel
                {
                    startTime = today.AddHours(8),
                    endTime = today.AddHours(16),
                    requiredDoctors = 2,
                    requiredNurses = 1,
                    departmentId = dep.id
                };

                var shift2 = new ShiftBindingModel
                {
                    startTime = today.AddHours(16),
                    endTime = today.AddHours(24),
                    requiredDoctors = 2,
                    requiredNurses = 1,
                    departmentId = dep.id
                };

                // GET список смен по departmentId
                Console.WriteLine($"Запрос смен: GetShiftList?departmentId={dep.id}");
                var shiftListUrl = $"GetShiftList?departmentId={dep.id}";
                var shiftListResponse = await client.GetAsync(shiftListUrl);
                Console.WriteLine($"HTTP {shiftListResponse.StatusCode}");
                if (!shiftListResponse.IsSuccessStatusCode)
                {
                    var err = await shiftListResponse.Content.ReadAsStringAsync();
                    Console.WriteLine($"Ошибка при запросе смен: {err}");
                    continue;
                }

                var existingShifts = await shiftListResponse.Content.ReadFromJsonAsync<List<ShiftViewModel>>();

                bool shift1Exists = existingShifts != null && existingShifts.Any(s => s.startTime == shift1.startTime && s.endTime == shift1.endTime);
                bool shift2Exists = existingShifts != null && existingShifts.Any(s => s.startTime == shift2.startTime && s.endTime == shift2.endTime);

                if (!shift1Exists)
                {
                    var createShiftResponse = await client.PostAsJsonAsync("CreateShift", shift1);
                    if (createShiftResponse.IsSuccessStatusCode)
                        Console.WriteLine($"Создана смена 08:00–16:00 для {dep.name}");
                    else
                    {
                        var err = await createShiftResponse.Content.ReadAsStringAsync();
                        Console.WriteLine($"Ошибка при создании смены 08:00–16:00: {err}");
                    }
                }
                else
                {
                    Console.WriteLine($"Смена 08:00–16:00 для {dep.name} уже существует");
                }

                if (!shift2Exists)
                {
                    var createShiftResponse = await client.PostAsJsonAsync("CreateShift", shift2);
                    if (createShiftResponse.IsSuccessStatusCode)
                        Console.WriteLine($"Создана смена 16:00–24:00 для {dep.name}");
                    else
                    {
                        var err = await createShiftResponse.Content.ReadAsStringAsync();
                        Console.WriteLine($"Ошибка при создании смены 16:00–24:00: {err}");
                    }
                }
                else
                {
                    Console.WriteLine($"Смена 16:00–24:00 для {dep.name} уже существует");
                }
            }

            Console.WriteLine("Все смены обработаны.");

            // === Ручное расписание для первого департамента ===
            var firstDep = departments[0];
            var shiftsForFirstDepResponse = await client.GetAsync($"GetShiftList?departmentId={firstDep.id}");
            if (!shiftsForFirstDepResponse.IsSuccessStatusCode)
            {
                var err = await shiftsForFirstDepResponse.Content.ReadAsStringAsync();
                Console.WriteLine($"Ошибка при получении смен для расписания: {err}");
                return;
            }
            var shiftListFirst = await shiftsForFirstDepResponse.Content.ReadFromJsonAsync<List<ShiftViewModel>>();

            var shiftsForSchedule = shiftListFirst!
            .Select(s => new ShiftBindingModel
            {
                id = s.id,
                startTime = s.startTime,
                endTime = s.endTime,
                requiredDoctors = s.requiredDoctors,
                requiredNurses = s.requiredNurses,
                departmentId = s.departmentId
            })
            .ToList(); // тип: List<ShiftBindingModel>

            var scheduleCreateResponse = await client.PostAsJsonAsync("CreateSchedule", new ScheduleBindingModel
            {
                date = DateTime.Today,
                departmentId = firstDep.id,
                shifts = shiftsForSchedule, // теперь всё совпадает
                assignments = new List<ScheduleAssignmentBindingModel>()
            });


            if (!scheduleCreateResponse.IsSuccessStatusCode)
            {
                var errorText = await scheduleCreateResponse.Content.ReadAsStringAsync();
                Console.WriteLine($"Ошибка при создании ручного расписания: HTTP {scheduleCreateResponse.StatusCode}");
                Console.WriteLine($"Тело ошибки: {errorText}");
            }
            else
            {
                Console.WriteLine($"Ручное расписание для {firstDep.name} создано");
            }


            // === Автоматическое расписание ===
            var autoDates = new List<DateTime>
            {
                DateTime.Today.AddDays(1),
                DateTime.Today.AddDays(2),
                DateTime.Today.AddDays(3),
                DateTime.Today.AddDays(4),
                DateTime.Today.AddDays(5)
            };

            foreach (var dep in departments)
            {
                var generateResponse = await client.PostAsJsonAsync("GenerateSchedule", new
                {
                    departmentId = dep.id,
                    dates = autoDates
                });

                Console.WriteLine(generateResponse.IsSuccessStatusCode
                    ? $"Автоматическое расписание для {dep.name} успешно создано"
                    : $"Ошибка генерации автоматического расписания для {dep.name}");
            }


            Console.WriteLine("Тестирование завершено.");
            string baseUrl = "http://localhost:5167/api/User";
            Console.WriteLine("Регистрация нового администратора...");

            var registerModel = new
            {
                login = "admin_test",
                password = "1234",
                fullname = "Test Admin",
                birthdate = DateTime.Parse("1990-01-01"),
                phoneNumber = "1234567890",
                vacationDates = new List<DateTime>(),
                role = 2, // Admin
                workedHours = 0.0
            };
            var regContent = new StringContent(
                JsonConvert.SerializeObject(registerModel),
                Encoding.UTF8,
                "application/json");

            var regResponse = await client.PostAsync($"{baseUrl}/Register", regContent);
            Console.WriteLine($"Ответ на регистрацию: {regResponse.StatusCode}");

            Console.WriteLine("Пробуем логин...");

            var loginUrl = $"{baseUrl}/Login?login=admin_test&password=1234";
            var loginResponse = await client.GetAsync(loginUrl);

            if (loginResponse.IsSuccessStatusCode)
            {
                var responseBody = await loginResponse.Content.ReadAsStringAsync();
                Console.WriteLine("Успешный логин. Ответ:");
                Console.WriteLine(responseBody);
            }
            else
            {
                Console.WriteLine($"Ошибка логина: {loginResponse.StatusCode}");
            }
        }


    }
}

